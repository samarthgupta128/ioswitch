# IO Switch Native Messaging Host for Windows
# Opens URLs in a specific browser (not the default)

# Read message length (4 bytes)
$stdin = [System.Console]::OpenStandardInput()
$lengthBytes = New-Object byte[] 4
$stdin.Read($lengthBytes, 0, 4) | Out-Null
$length = [System.BitConverter]::ToInt32($lengthBytes, 0)

# Read message
$messageBytes = New-Object byte[] $length
$stdin.Read($messageBytes, 0, $length) | Out-Null
$message = [System.Text.Encoding]::UTF8.GetString($messageBytes)

# Parse JSON
$data = $message | ConvertFrom-Json
$url = $data.url

# List of browsers to try (in order of preference)
# Add or reorder based on your preference
$browsers = @(
    @{ Name = "Chrome"; Paths = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
    )},
    @{ Name = "Edge"; Paths = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
    )},
    @{ Name = "Brave"; Paths = @(
        "${env:ProgramFiles}\BraveSoftware\Brave-Browser\Application\brave.exe",
        "${env:LOCALAPPDATA}\BraveSoftware\Brave-Browser\Application\brave.exe"
    )},
    @{ Name = "Vivaldi"; Paths = @(
        "${env:LOCALAPPDATA}\Vivaldi\Application\vivaldi.exe"
    )},
    @{ Name = "Opera"; Paths = @(
        "${env:LOCALAPPDATA}\Programs\Opera\opera.exe"
    )}
)

$opened = $false

foreach ($browser in $browsers) {
    foreach ($path in $browser.Paths) {
        if (Test-Path $path) {
            Start-Process -FilePath $path -ArgumentList $url
            $opened = $true
            break
        }
    }
    if ($opened) { break }
}

# Fallback: If no browser found, try default (last resort)
if (-not $opened) {
    Start-Process $url
}

# Send response
$response = '{"success":true}'
$responseBytes = [System.Text.Encoding]::UTF8.GetBytes($response)
$responseLengthBytes = [System.BitConverter]::GetBytes($responseBytes.Length)

$stdout = [System.Console]::OpenStandardOutput()
$stdout.Write($responseLengthBytes, 0, 4)
$stdout.Write($responseBytes, 0, $responseBytes.Length)
$stdout.Flush()