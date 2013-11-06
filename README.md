libconfig_mex
=============

Matlab mex wrapper for libconfig

---------------------
Building with cmake:

create a build directory

  mkdir build
  cd build
  
Run CMake

  ccmake ../src/
  
Note: you might need to set the correct path to your Matlab in src/CMakeLists.txt
  
Build

  make
  cp LibConfigMex.mexa64 ../dist/
  
--------------------
Usage in Matlab:

add the dist folder to the Matlab path

  addpath(/YOUR/PATH/TO/LIBCONFIG_MEX/dist)
  
Then use:

  cfgFile = LibConfig('/YOUR/PATH/TO/LIBCONFIG_MEX/dist/test.cfg');
  cfg = cfgFile.readAll();
  delete(cfgFile);
  
