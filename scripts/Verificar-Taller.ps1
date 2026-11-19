[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskRun = Get-Date -Format 'yyyyMMdd-HHmmss'
$taskEvidence = Join-Path $taskRoot "evidencias/$taskRun"
New-Item -ItemType Directory -Path $taskEvidence -Force | Out-Null
$taskDocker = (Get-Command docker -ErrorAction Stop).Source

function Invoke-TaskDocker {
    param([string]$Log, [string[]]$DockerArgs)
    Write-Host ("docker " + ($DockerArgs -join ' '))
    # Windows PowerShell 5.1 convierte stderr nativo en ErrorRecord.
    # BuildKit usa stderr incluso para progreso correcto: comprobar el exit code.
    $taskPreviousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $taskDocker @DockerArgs 2>&1 | ForEach-Object { $_.ToString() } |
            Tee-Object -FilePath (Join-Path $taskEvidence "$Log.txt")
        $taskExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $taskPreviousPreference
    }
    if ($taskExitCode -ne 0) { throw "Falló docker ($Log), código $taskExitCode. Consulte las evidencias." }
}

Invoke-TaskDocker -Log '00-version' -DockerArgs @('version')
foreach ($taskPort in @(4001, 4002, 8082)) {
    if (Get-NetTCPConnection -LocalPort $taskPort -State Listen -ErrorAction SilentlyContinue) {
        throw "El puerto $taskPort ya está ocupado. No se detuvo ningún servicio existente."
    }
}
Invoke-TaskDocker -Log '01-helloapp' -DockerArgs @('build','--progress=plain','-t','helloapp:v1',(Join-Path $taskRoot 'hello-world'))
$taskApp = Join-Path $taskRoot 'friendlyhello'
Invoke-TaskDocker -Log '02-check' -DockerArgs @('build','--check',$taskApp)
Invoke-TaskDocker -Log '03-build' -DockerArgs @('build','--progress=plain','-t','friendlyhello:taller-verificado',$taskApp)

# Cambiar solo el código en copias aisladas permite comparar ambas estrategias.
$taskTimes = @()
foreach ($taskStrategy in @('optimizado','copy-antes-de-pip')) {
    $taskContext = Join-Path $taskEvidence $taskStrategy
    New-Item -ItemType Directory -Path $taskContext | Out-Null
    foreach ($taskFile in @('app.py','requirements.txt','Dockerfile','.dockerignore')) {
        Copy-Item -LiteralPath (Join-Path $taskApp $taskFile) -Destination $taskContext
    }
    if ($taskStrategy -eq 'copy-antes-de-pip') {
        $taskDockerfile = Join-Path $taskContext 'Dockerfile'
        $taskText = [IO.File]::ReadAllText($taskDockerfile)
        $taskText = $taskText.Replace('COPY requirements.txt .', 'COPY . .')
        [IO.File]::WriteAllText($taskDockerfile, $taskText)
    }
    Invoke-TaskDocker -Log "04-base-$taskStrategy" -DockerArgs @('build','--progress=plain','-t',"friendlyhello:cache-$taskStrategy",$taskContext)
    $taskCodeFile = Join-Path $taskContext 'app.py'
    $taskCode = [IO.File]::ReadAllText($taskCodeFile).Replace('Hola!!!', 'Hola cache')
    [IO.File]::WriteAllText($taskCodeFile, $taskCode)
    $taskTimer = [Diagnostics.Stopwatch]::StartNew()
    Invoke-TaskDocker -Log "05-cambio-$taskStrategy" -DockerArgs @('build','--progress=plain','-t',"friendlyhello:cache-$taskStrategy",$taskContext)
    $taskTimer.Stop()
    $taskTimes += [pscustomobject]@{Estrategia=$taskStrategy; Segundos=[math]::Round($taskTimer.Elapsed.TotalSeconds,3)}
}
$taskTimes | Export-Csv (Join-Path $taskEvidence 'tiempos.csv') -NoTypeInformation -Encoding utf8

$taskSolo = "taller-solo-$taskRun"
try {
    Invoke-TaskDocker -Log '06-sin-redis-inicio' -DockerArgs @('run','-d','--name',$taskSolo,'-p','127.0.0.1:4001:8000','friendlyhello:taller-verificado')
    $taskResponse = $null
    for ($taskAttempt=0; $taskAttempt -lt 20; $taskAttempt++) {
        try { $taskResponse = Invoke-WebRequest 'http://localhost:4001/' -UseBasicParsing -TimeoutSec 10; break }
        catch { Start-Sleep -Seconds 1 }
    }
    if (-not $taskResponse -or $taskResponse.Content -notmatch 'counter disabled') { throw 'No se verificó el manejo de Redis ausente.' }
    $taskResponse.Content | Set-Content (Join-Path $taskEvidence 'sin-redis.html') -Encoding utf8
    Invoke-TaskDocker -Log '07-usuario' -DockerArgs @('exec',$taskSolo,'id')
} finally {
    # Solo elimina el contenedor desechable creado por este script.
    & $taskDocker rm -f $taskSolo | Out-Null
}

$taskCompose = Join-Path $taskEvidence 'compose-prueba.yaml'
@'
services:
  web:
    image: friendlyhello:taller-verificado
    ports:
      - "127.0.0.1:4001:8000"
    depends_on:
      redis:
        condition: service_healthy
  redis:
    image: redis:8.8
    command: redis-server --appendonly yes
    volumes:
      - datos:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
volumes:
  datos:
'@ | Set-Content $taskCompose -Encoding utf8
$taskProject = "taller-verificacion-$taskRun"
$taskComposeArgs = @('compose','-p',$taskProject,'-f',$taskCompose)
Invoke-TaskDocker -Log '08-compose' -DockerArgs ($taskComposeArgs + @('up','-d','--wait','--wait-timeout','120'))
Invoke-TaskDocker -Log '09-compose-ps' -DockerArgs ($taskComposeArgs + @('ps'))
$taskBefore = (Invoke-WebRequest 'http://localhost:4001/' -UseBasicParsing).Content
$taskAfter = (Invoke-WebRequest 'http://localhost:4001/' -UseBasicParsing).Content
$taskBefore | Set-Content (Join-Path $taskEvidence 'redis-visita-1.html') -Encoding utf8
$taskAfter | Set-Content (Join-Path $taskEvidence 'redis-visita-2.html') -Encoding utf8
$taskBeforeVisits = [int]([regex]::Match($taskBefore,'Visits:</b> (\d+)').Groups[1].Value)
$taskAfterVisits = [int]([regex]::Match($taskAfter,'Visits:</b> (\d+)').Groups[1].Value)
if ($taskAfterVisits -le $taskBeforeVisits) { throw 'El contador de Redis no aumentó.' }
Invoke-TaskDocker -Log '10-detener-compose' -DockerArgs ($taskComposeArgs + @('down'))
Invoke-TaskDocker -Log '11-persistencia-arranque' -DockerArgs ($taskComposeArgs + @('up','-d','--wait','--wait-timeout','120'))
$taskPersist = (Invoke-WebRequest 'http://localhost:4001/' -UseBasicParsing).Content
$taskPersist | Set-Content (Join-Path $taskEvidence 'redis-persistencia.html') -Encoding utf8
$taskPersistVisits = [int]([regex]::Match($taskPersist,'Visits:</b> (\d+)').Groups[1].Value)
if ($taskPersistVisits -le $taskAfterVisits) { throw 'No se verificó persistencia tras recrear los contenedores.' }
Invoke-TaskDocker -Log '12-detener-compose' -DockerArgs ($taskComposeArgs + @('down'))

$taskBalanced = Join-Path $taskEvidence 'compose-balanceo.yaml'
$taskConfig = [IO.File]::ReadAllText((Join-Path $taskApp 'docker-compose.traefik.yaml'))
$taskConfig = $taskConfig.Replace('build: .','image: friendlyhello:taller-verificado')
$taskConfig = $taskConfig.Replace('"4000:4000"','"127.0.0.1:4002:4000"').Replace('"8080:8080"','"127.0.0.1:8082:8080"')
$taskConfig = $taskConfig.Replace('./data:/data','datos:/data') + "`nvolumes:`n  datos:`n"
[IO.File]::WriteAllText($taskBalanced,$taskConfig)
$taskBalanceArgs = @('compose','-p',$taskProject,'-f',$taskBalanced)
Invoke-TaskDocker -Log '13-cinco-replicas' -DockerArgs ($taskBalanceArgs + @('up','-d','--scale','web=5','--wait','--wait-timeout','120'))
Invoke-TaskDocker -Log '14-balanceo-ps' -DockerArgs ($taskBalanceArgs + @('ps'))
$taskSamples = foreach ($taskIndex in 1..20) {
    $taskHtml = (Invoke-WebRequest 'http://localhost:4002/' -UseBasicParsing -TimeoutSec 10).Content
    $taskHtml | Set-Content (Join-Path $taskEvidence "balanceo-$taskIndex.html") -Encoding utf8
    [pscustomobject]@{
        Peticion=$taskIndex
        Hostname=[regex]::Match($taskHtml,'Hostname:</b> ([^<]+)').Groups[1].Value
        Visitas=[regex]::Match($taskHtml,'Visits:</b> (\d+)').Groups[1].Value
    }
}
$taskSamples | Export-Csv (Join-Path $taskEvidence 'balanceo.csv') -NoTypeInformation -Encoding utf8
$taskHosts = @($taskSamples.Hostname | Sort-Object -Unique)
if ($taskHosts.Count -ne 5) { throw "Se observaron $($taskHosts.Count) hostnames; se esperaban cinco." }
$taskDashboard = Invoke-WebRequest 'http://localhost:8082/api/http/services' -UseBasicParsing
$taskDashboard.Content | Set-Content (Join-Path $taskEvidence 'traefik-servicios.json') -Encoding utf8
Write-Host "Pruebas completadas. Evidencias: $taskEvidence"
Write-Host 'Capturas: http://localhost:4002 y http://localhost:8082/dashboard/'
Write-Host ("Para detener solo este despliegue: docker compose -p $taskProject -f `"$taskBalanced`" down")
