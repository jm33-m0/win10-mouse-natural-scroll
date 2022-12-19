# Enable natural scrolling for all configured USB mice on the system - pulling
# down the mouse wheel pulls the screen area down, showing the text above.
#
# Use the "reverse" argument to enable unnatural a.k.a. Microsoft default
# scrolling - pulling down the mouse wheel shows the text below.
#
# Run this script in PowerShell as administrator.
#
# The mouse behavior changes only after rebooting the system.

$setting_names = @("DEFAULT", "NATURAL")

if ($args[0] -eq "reverse") {
    $target_setting = 0
} else {
    $target_setting = 1
}

$mice = Get-PnpDevice -Class Mouse
if (!$mice) {
    Write-Host -ForegroundColor Red "Could not find any USB mouse"
    exit 1
}

# set up every mouse
foreach ($mouse in $mice) {
    $name = $mouse.FriendlyName
    $path = $mouse.InstanceID

    if (!($path -like "HID\VID*")) {
        Write-Host "Not a compatible mouse, skipping: $name ($path)"
        continue
    }

    Write-Host "Found $name ($path)"

    # the reg path has changed since win11
    $reg_path = "HKLM:\SYSTEM\CurrentControlSet\Enum\$path\Device Parameters"

    $current_setting = (Get-ItemProperty -Path $reg_path -Name FlipFlopWheel).FlipFlopWheel

    if ($current_setting -ne $target_setting) {
        # Check if we have admin rights
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
             Write-Host -ForegroundColor Red "Need admin privilege to modify the registry"
             exit 1
        }
        Set-ItemProperty -Path $reg_path -Name FlipFlopWheel -Value $target_setting
        Write-Host -ForegroundColor Green "Scrolling setting has been set to" $setting_names[$target_setting]
    } else {
        Write-Host "Keeping the current scrolling setting:" $setting_names[$current_setting]
    }
}
