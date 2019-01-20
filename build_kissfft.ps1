param([string]$LibraryType = "SHARED")

$ModuleName = "kissfft"
$RootSourcePath = "./jni"
$FinalSourceFolder = "tools"
$SourceFilePattern = "*.c"
$MakeFileName = "Android.mk"
$ExcludedFolders = "test|LICENSES"
$ExcludedFiles = "psdpng.c|fftutil.c"
$NdkBuild = "Android/Sdk/ndk-bundle/ndk-build.cmd"
$StaticBuildRoot = "./obj/local/"
$SharedBuildRoot = "./libs/"
$OutputDir = "out"

$IncludeFilePattern = "*.h"
$IncludeFileDest = "./$OutputDir/include"

# Relocate Root Source and Header Files to Final Source Path
Write-Output "Copying Root Source & Header Files to Final Source Path..."
Push-Location $RootSourcePath
$rootSourceFiles = (Get-ChildItem -Path $SourceFilePattern).Name
$rootHeaderFiles = (Get-ChildItem -Path $IncludeFilePattern).Name
foreach ($sourceFile in $rootSourceFiles) {
    $fileDestination = "$FinalSourceFolder/$sourceFile"
    New-Item -Force $fileDestination
    Copy-Item -Force $sourceFile -Destination $fileDestination
}
foreach ($headerFile in $rootHeaderFiles) {
    $fileDestination = "$FinalSourceFolder/$headerFile"
    New-Item -Force $fileDestination
    Copy-Item -Force $headerFile -Destination $fileDestination
}
Pop-Location
Write-Output "Successfully copied Root Source & Header Files to Final Source Path!"

# Find Source Directories
Push-Location $RootSourcePath
$sourceDirectories = "tools"

# Assemble Root Make File Header
Write-Output "Assembling Root Android Make File Header..."
$rootMakeContents = @"
LOCAL_PATH := `$(call my-dir)
include `$(CLEAR_VARS)


"@
Write-Output "Successfully assembled Root Android Make File Header!`n"

$C_Directories = ""
foreach ($sourceDir in $sourceDirectories) {
    Write-Output "Finding Source Files in directory : $sourceDir ..."
    $sourceFiles = (Get-ChildItem -Path $sourceDir/$SourceFilePattern | Where { $_.Name -NotMatch $ExcludedFiles }).Name
    
    if ($sourceFiles) {
        # Create Subdirectory Make File
        Write-Output "Assembling Android Make File for directory : $sourceDir ..."
        $cleanSourceDir = $sourceDir.Replace(".\", "").Replace("\", "/")
        $dirMakeContents = "sources :="
        foreach ($sourceFile in $sourceFiles) {
            $dirMakeContents = $dirMakeContents + " $sourceFile"
        }
        $dirMakeContents = $dirMakeContents + "`n"
        $dirMakeContents = $dirMakeContents + "LOCAL_SRC_FILES += `$(addprefix $cleanSourceDir/, `$(sources))`n"
        Write-Output "Creating Android Make File for directory : $sourceDir ..."
        Out-File -FilePath $sourceDir/$MakeFileName -InputObject $dirMakeContents -Encoding ASCII
        Write-Output "Successfully created Android Make File for directory : $sourceDir !"
        
        # Add Subdirectory Make File to Root Make File
        Write-Output "Assembling entry to Root Android Make File for directory : $sourceDir ..."
        $rootMakeContents = $rootMakeContents + "include `$(LOCAL_PATH)/$cleanSourceDir/$MakeFileName`n"
        $C_Directories = $C_Directories + " `$(LOCAL_PATH)/$cleanSourceDir"
        Write-Output "Successfully assembled entry to Root Android Make File for directory : $sourceDir !"
    }
    else {
        Write-Output "No Source Files found. Skipping directory : $sourceDir !"
    }
    
    Write-Output ""
}

# Assemble Root Make File Footer
Write-Output "Assembling Root Android Make File Footer..."
$rootMakeContents = $rootMakeContents + "`n"
$rootMakeContents = $rootMakeContents + "LOCAL_MODULE := $ModuleName`n"
$rootMakeContents = $rootMakeContents + "LOCAL_C_INCLUDES :=  `$(LOCAL_PATH)/"
$rootMakeContents = $rootMakeContents + "$C_Directories`n"
$rootMakeContents = $rootMakeContents + "LOCAL_CFLAGS += -x c++`n`n"
$rootMakeContents = $rootMakeContents + "include `$(BUILD_" + $LibraryType.ToUpper() + "_LIBRARY)`n"
Write-Output "Creating Root Android Make File..."
Out-File -FilePath $MakeFileName -InputObject $rootMakeContents -Encoding ASCII
Write-Output "Successfully created Root Android Make File!`n"
Pop-Location

# Execute ndk-build
Write-Output "Executing ndk-build..."
. $env:LOCALAPPDATA\$NdkBuild
if ($LASTEXITCODE -ne 0) {
    Write-Output "NDK-Build failed!  Exit Code : $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Output "NDK-Build completed successfully!"

# Copy Build Output to more convenient location
Write-Output "Copying Build Output to ./$OutputDir ..."
$libraryFilePattern = "*.bogus"
If($LibraryType -eq "STATIC") { 
    $libraryFilePattern = "*.a"
    $buildRoot = $StaticBuildRoot
    $buildOutput = "../../$OutputDir"
} ElseIf($LibraryType -eq "SHARED") {
    $libraryFilePattern = "*.so"
    $buildRoot = $SharedBuildRoot
    $buildOutput = "../$OutputDir"
}
Push-Location $buildRoot
$libraryFiles = (Get-ChildItem -Path $libraryFilePattern -Recurse).FullName | Resolve-Path -Relative
foreach ($libFile in $libraryFiles) {
    $libFileDest = "$buildOutput/" + $libFile.Replace(".\", "").Replace("\", "/")
    Write-Output "Copying $libFile to $libFileDest ..."
    New-Item -Force $libFileDest
    Copy-Item -Force $libFile -Destination $libFileDest
}
Pop-Location
Write-Output "Successfully copied Build Output to $BuildOutput !"

# Copy Include Files
Write-Output "Copying Include Files to $IncludeFileDest ..."
foreach ($sourceDir in $sourceDirectories) {
    Push-Location $RootSourcePath/$sourceDir
    $includeFiles = (Get-ChildItem -Path $IncludeFilePattern).FullName | Resolve-Path -Relative
    foreach ($includeFile in $includeFiles) {
        $fileDestination = "../../$IncludeFileDest/$includeFile"
        New-Item -Force $fileDestination
        Copy-Item -Force $includeFile -Destination $fileDestination
    }
    Pop-Location
}
