Write-Host "Finding your USB mouse..." -ForegroundColor Cyan

$mouses = Get-PnpDevice -Class Mouse
if (!$mouses) {
    Write-Host -ForegroundColor Red "Could not find your USB mouse"
    exit 1
}

# set up every mouse 
foreach ($mouse in $mouses) {
    $name = $mouse.FriendlyName
    $path = $mouse.InstanceID

    if (!($path -like "HID\VID*")) {
        Write-Host -ForegroundColor Yellow "Skipping"$path
        continue
    }
    Write-Host -ForegroundColor Blue "We have"$path

    Write-Host "Found $name ($path)" -ForegroundColor Green 
    Write-Host "Configuring natural scrolling feature for your mouse..." -ForegroundColor Cyan

    # check if we have admin
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host -ForegroundColor Red "Need admin privilege to modify the registry"
        exit 1
    }

    # the reg path has changed since win11
    $reg_path = "HKLM:\SYSTEM\CurrentControlSet\Enum\$path\Device Parameters"

    if ($args[0] -eq "reverse") {
        Set-ItemProperty -Path $reg_path -Name FlipFlopWheel -Value 0
        Write-Host "Natural scrolling feature for your mouse has been DISABLED" -ForegroundColor Green
        exit
    }
    Set-ItemProperty -Path $reg_path -Name FlipFlopWheel -Value 1
    Write-Host "Natural scrolling feature for your mouse has been ENABLED" -ForegroundColor Green
}