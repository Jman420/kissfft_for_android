$RootSourcePath = "./jni"
$RepoUrl = "https://github.com/mborgerding/kissfft/archive/master.zip"
$RepoZipFile = "./kissfft-master.zip"
$RootZipFolder = "kissfft-master"

Write-Output "Preparing KissFFT Source Code Directory..."
if (Test-Path $RepoZipFile) {
    Write-Output "Removing existing KissFFT Repo Zip File..."
    Remove-Item $RepoZipFile -Force
}
Write-Output "Downloading KissFFT Repo Zip File..."
Start-BitsTransfer -Source $RepoUrl -Destination $RepoZipFile

if (Test-Path $RootSourcePath) {
    Write-Output "Removing KissFFT Source Code Directory..."
    Remove-Item $RootSourcePath -Recurse -Force
}
Write-Output "Unzipping KissFFT Repo to KissFFT Source Code Directory..."
7z x "$RepoZipFile" -r
mv ./$RootZipFolder $RootSourcePath
Write-Output "Successfully prepared KissFFT Source Code!"
