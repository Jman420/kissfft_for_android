# Building KissFFT for Android

The [build_kissfft.ps1](build_kissfft.ps1) script is a PowerShell script which will automatically generate the necessary Android Make files for ndk-build to compile KissFFT for Android.

## Steps
  - Download the latest build of KissFFT from [https://github.com/mborgerding/kissfft](https://github.com/mborgerding/kissfft) (downloading the entire repository as a Zip File will suffice)
  - Unzip the archive to the /jni/ directory
  - Execute the [build_kissfft.ps1](build_kissfft.ps1) script
  - Resulting files are in /out/ directory

## Notes

### Building KissFFT Static Library
By default the [build_kissfft.ps1](build_kissfft.ps1) script will compile a Shared Library for KissFFT.  If you want a Static Library instead execute ```build_kissfft.ps1 -LibraryType STATIC```.

### KissFFT Precision
The default configuration for KissFFT contained within the kiss_fft.h file will compile FFTW with single precision.  This means that all of the KissFFT methods will use float data type for their calculations and parameters.  This is because Android AudioFlinger currently provides and expects float32 as the largest data type it will handle.

To build KissFFT with a different precision simply change the data type in the following line in kiss_fft.h and re-run [build_kissfft.ps1](build_kissfft.ps1) :
  - #define kiss_fft_scalar float
