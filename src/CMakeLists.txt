PROJECT(LibConfigMexProj)

cmake_minimum_required(VERSION 2.6)

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules")

# skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  TRUE)

# when building, use the install RPATH already
# (so it doesn't need to relink when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE) 

# the RPATH to be used when installing
SET(CMAKE_INSTALL_RPATH "/lib:/usr/lib:${CMAKE_SOURCE_DIR}/lib/glnxa64")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

SET(CMAKE_VERBOSE_MAKEFILE ON) 

#####################################################
#   Matlab 
#####################################################

SET(MATLAB_ROOT /usr/local/MATLAB/R2013b)
FIND_PACKAGE(Matlab REQUIRED)  
INCLUDE_DIRECTORIES(${MATLAB_INCLUDE_DIRS})

MESSAGE("M1 ${MATLAB_INCLUDE_DIRS}")
MESSAGE("M2 ${MATLAB_INCLUDE_DIR}")

#SET(MATLAB_LIBRARIES mex mx mat)

#IF(WIN32)
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2006a/extern/include )
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2006b/extern/include )
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2007a/extern/include )
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2007b/extern/include )
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2008a/extern/include )
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2008b/extern/include )
#  INCLUDE_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2009a/extern/include )
# 
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2006a/extern/lib/win32/microsoft )
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2006b/extern/lib/win32/microsoft )
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2007a/extern/lib/win32/microsoft )
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2007b/extern/lib/win32/microsoft )
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2008a/extern/lib/win32/microsoft )
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2008b/extern/lib/win32/microsoft )
#  LINK_DIRECTORIES( $ENV{ProgramFiles}/MATLAB/R2009a/extern/lib/win32/microsoft )
#
#  SET(MATLAB_LIBRARIES libeng libmex libmx)
#ELSE(WIN32)
#
#  INCLUDE_DIRECTORIES(/usr/local/matlab/extern/include)
#  LINK_DIRECTORIES(/usr/local/matlab/bin/glnxa64)
#
#  SET(MATLAB_LIBRARIES mex mx mat)
#
#ENDIF(WIN32)

#######################################################
# libconfig++
#######################################################
FIND_PACKAGE(LibConfig REQUIRED)
INCLUDE_DIRECTORIES(${LIBCONFIG_INCLUDE_DIRS})

#####################################################
#   SETUP SHARED LIB
#####################################################

ADD_LIBRARY(LibConfigMex SHARED libconfigmex.cpp LibConfigMexWrapper.cpp LibConfigMexWrapper.h)
IF(WIN32)
  SET_TARGET_PROPERTIES(LibConfigMex PROPERTIES SUFFIX .mexw32)
  SET_TARGET_PROPERTIES(LibConfigMex PROPERTIES LINK_FLAGS "/export:mexFunction")
ELSE(WIN32)
  SET_TARGET_PROPERTIES(LibConfigMex PROPERTIES PREFIX "")
  SET_TARGET_PROPERTIES(LibConfigMex PROPERTIES SUFFIX .mexa64)
ENDIF(WIN32)
TARGET_LINK_LIBRARIES(LibConfigMex ${MATLAB_LIBRARIES} ${LIBCONFIG_LIBRARIES})

