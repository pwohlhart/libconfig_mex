libconfig_mex
=============

Matlab mex wrapper for libconfig

---------------------
Building with cmake:

* create a build directory

```bash
mkdir build
cd build
```  

* Run CMake

```bash
ccmake ../src/
```
  
  Note: you might need to set the correct path to your Matlab in src/CMakeLists.txt
  
* Build

```bash
make
cp LibConfigMex.mexa64 ../dist/
```
  
--------------------
Usage in Matlab:

* add the dist folder to the Matlab path

```matlab
  addpath(/YOUR/PATH/TO/LIBCONFIG_MEX/dist)
```
  
* then use:

```matlab
  cfgFile = LibConfig('/YOUR/PATH/TO/LIBCONFIG_MEX/dist/test.cfg');
  cfg = cfgFile.readAll();
  delete(cfgFile);
```
  
