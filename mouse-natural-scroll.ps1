Write-Host "Finding your USB mouse..." -ForegroundColor Cyan

$mouses = Get-CimInstance -ClassName Win32_PointingDevice | Where-Object Name -Match "HID-compliant mouse"
if (!$mouses) {
    Write-Host -ForegroundColor Red "Could not find your USB mouse"
    exit 1
}

# set up every mouse 
foreach ($mouse in $mouses) {
    if (!($mouse.DeviceID -like "HID\VID*")) {
        Write-Host -ForegroundColor Yellow "Skipping"$mouse.DeviceID
        continue
    }
    Write-Host -ForegroundColor Blue "We have"$mouse.DeviceID
    $usb_mouse = $mouse.DeviceID
    $id = $usb_mouse.split("\\")[1]
    $device = Get-PnpDevice -PresentOnly -Class Mouse | Where-Object DeviceID -Match $id 
    $name = $device | Select-Object -ExpandProperty FriendlyName
    $path = $device | Select-Object -ExpandProperty InstanceId

    Write-Host "Found $name ($path)" -ForegroundColor Green 
    Write-Host "Configuring natural scrolling feature for your mouse..." -ForegroundColor Cyan

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host -ForegroundColor Red "Need admin privilege to modify the registry"
        exit 1
    }

    if ($args[0] -eq "reverse") {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$path\Device Parameters" -Name FlipFlopWheel -Value 0
        Write-Host "Natural scrolling feature for your mouse has been DISABLED" -ForegroundColor Green
        exit
    }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$path\Device Parameters" -Name FlipFlopWheel -Value 1
    Write-Host "Natural scrolling feature for your mouse has been ENABLED" -ForegroundColor Green
}