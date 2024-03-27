
$global:modus = $null
$global:buildnumber = $null
Set-Variable BUILDNR_FILE -Option Constant -Value 'build-number.txt'

#--------------------------------------------------------
Function askModus{
    Write-host "Geef deploy modus prod of acc" -ForegroundColor Cyan
    $global:modus = Read-Host 
    
    # Check the modus and create the files:
    if ( $global:modus -eq "prod" -or $global:modus -eq "acc" ) {
        Write-host "Deploying to $global:modus" -ForegroundColor Cyan
    } else {
        Write-host "Onbekende modus" -ForegroundColor Cyan
        exit
    }
    
}
# Function copyFiles {
#     $dest = ".\firebase.json"
#     $src = $dest + "." +  $global:modus
#     Write-host "Copy $src to $dest" 
#     [System.IO.File]::Copy($src, $dest, $true);

#     $dest = ".\.firebaserc"
#     $src = $dest + "." +  $global:modus
#     Write-host "Copy $src to $dest" 
#     [System.IO.File]::Copy($src, $dest, $true);
# }

#--------------------------------------------------------
Function writeRunModeFile {
    Write-host "Write file ..." 
    $mode = $Global:modus
    $date = Get-Date -Format "dd-MMM-yyyy"

    $code = @"

import 'package:rooster/model/app_models.dart';

RunMode appRunModus = RunMode.{0};
String appVersion = '{1} buildnr: {2}';

"@ -f $mode, $date, $global:buildnumber.ToString()

    $filename = ".\lib\data\app_version.dart"
    [IO.File]::WriteAllLines($filename, $code)
}

#--------------------------------------------------------
Function runFirebaseScripts{
    Write-host "Run scripts ..." 
    flutter clean
    flutter build web --web-renderer html
    Remove-Item '.firebase' -Force -Recurse
    firebase deploy --only hosting:$global:modus
}

#--------------------------------------------------------
Function getBuildNumber{
    Write-host "Get and increment build number from $BUILDNR_FILE ..." 
    $txt = Get-Content -path $BUILDNR_FILE
    $global:buildnumber = [int]$txt

    #increment build number
    $increment_number = $global:buildnumber + 1
    Set-Content -Path $BUILDNR_FILE -Value $increment_number
}

#--------------------------------------------------------
askModus;
getBuildNumber;
writeRunModeFile;
runFirebaseScripts