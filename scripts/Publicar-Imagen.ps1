[CmdletBinding()]
param(
    [string]$DockerUser = 'gaxxenor',
    [string]$Version = '0.1.0'
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskRun = Get-Date -Format 'yyyyMMdd-HHmmss'
$taskEvidence = Join-Path $taskRoot "evidencias/registro-$taskRun"
New-Item -ItemType Directory -Path $taskEvidence -Force | Out-Null
$taskDocker = (Get-Command docker -ErrorAction Stop).Source
if ($DockerUser -notmatch '^[a-z0-9][a-z0-9_-]*$' -or $Version -notmatch '^[a-zA-Z0-9_][a-zA-Z0-9_.-]*$') {
    throw 'Usuario o etiqueta de Docker no válidos.'
}

function Invoke-RegistryDocker {
    param([string]$Log, [string[]]$DockerArgs)
    Write-Host ("docker " + ($DockerArgs -join ' '))
    $taskPreviousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $taskDocker @DockerArgs 2>&1 | ForEach-Object { $_.ToString() } |
            Tee-Object -FilePath (Join-Path $taskEvidence "$Log.txt")
        $taskExitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $taskPreviousPreference }
    if ($taskExitCode -ne 0) {
        throw "Falló docker ($Log), código $taskExitCode. Si falta sesión, ejecute docker login y vuelva a intentar."
    }
}

if (Get-NetTCPConnection -LocalPort 4003 -State Listen -ErrorAction SilentlyContinue) {
    throw 'El puerto 4003 está ocupado. No se detuvo ningún servicio existente.'
}
$taskImage = "$DockerUser/friendlyhello"
Invoke-RegistryDocker -Log '01-imagen-probada' -DockerArgs @('image','inspect','friendlyhello:taller-verificado','--format','{{.Id}}')
Invoke-RegistryDocker -Log '02-tag-version' -DockerArgs @('tag','friendlyhello:taller-verificado',"${taskImage}:$Version")
Invoke-RegistryDocker -Log '03-tag-latest' -DockerArgs @('tag','friendlyhello:taller-verificado',"${taskImage}:latest")
Invoke-RegistryDocker -Log '04-push-version' -DockerArgs @('push',"${taskImage}:$Version")
Invoke-RegistryDocker -Log '05-push-latest' -DockerArgs @('push',"${taskImage}:latest")
Invoke-RegistryDocker -Log '06-manifest-version' -DockerArgs @('buildx','imagetools','inspect',"${taskImage}:$Version")
Invoke-RegistryDocker -Log '07-manifest-latest' -DockerArgs @('buildx','imagetools','inspect',"${taskImage}:latest")

# Prueba independiente usando image, sin build, descargando del registro.
$taskCompose = Join-Path $taskEvidence 'compose-registro.yaml'
$taskConfig = [IO.File]::ReadAllText((Join-Path $taskRoot 'friendlyhello/docker-compose.registro.yaml'))
$taskConfig = $taskConfig.Replace('127.0.0.1:4000:8000','127.0.0.1:4003:8000')
[IO.File]::WriteAllText($taskCompose,$taskConfig)
$taskPriorWebImage = $env:WEB_IMAGE
try {
    $env:WEB_IMAGE = "${taskImage}:$Version"
    $taskComposeArgs = @('compose','-p',"taller-registro-$taskRun",'-f',$taskCompose)
    Invoke-RegistryDocker -Log '08-pull-despliegue' -DockerArgs ($taskComposeArgs + @('up','-d','--pull','always','--wait','--wait-timeout','120'))
    Invoke-RegistryDocker -Log '09-compose-ps' -DockerArgs ($taskComposeArgs + @('ps'))
    $taskResponse = (Invoke-WebRequest 'http://localhost:4003/' -UseBasicParsing -TimeoutSec 10).Content
    $taskResponse | Set-Content (Join-Path $taskEvidence 'imagen-registro.html') -Encoding utf8
    if ($taskResponse -notmatch 'Visits:</b> \d+') { throw 'La imagen descargada no mostró un contador funcional.' }
    "https://hub.docker.com/r/$DockerUser/friendlyhello" | Set-Content (Join-Path $taskEvidence 'enlace.txt') -Encoding utf8
    Write-Host "Publicación y descarga verificadas. Evidencias: $taskEvidence"
    Write-Host 'Aplicación de la imagen publicada: http://localhost:4003'
} finally { $env:WEB_IMAGE = $taskPriorWebImage }
