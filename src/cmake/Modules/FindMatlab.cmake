# - this module looks for Matlab
# Defines:
#  MATLAB_INCLUDE_DIRS: include path for mex.h, engine.h
#  MATLAB_LIBRARIES:   required libraries: libmex, etc
#  MATLAB_MEX_LIBRARY: path to libmex.lib
#  MATLAB_MX_LIBRARY:  path to libmx.lib
#  MATLAB_UT_LIBRARY:  path to libut.so
#  MATLAB_ENG_LIBRARY: path to libeng.lib
#  MATLAB_ROOT: path to Matlab's root directory

#=============================================================================
#  Modifications by Paul Wohlhart (wohlhart@icg.tugraz.at):
#    * find extension for mex file: MATLAB_SUFFIX
#    * use FIND_LIBRARY for the libs
#    * use FIND_PACKAGE_HANDLE_STANDARD_ARGS for finishing
#
#  otherwise based on:

# This file is part of Gerardus
#
# This is a derivative work of file FindMatlab.cmake released with
# CMake v2.8, because the original seems to be a bit outdated and
# doesn't work with my Windows XP and Visual Studio 10 install
#
# (Note that the original file does work for Ubuntu Natty)
#
# Author: Ramon Casero <rcasero@gmail.com>, Tom Doel
# Version: 0.2.9
# $Rev$
# $Date$
#
# The original file was copied from an Ubuntu Linux install
# /usr/share/cmake-2.8/Modules/FindMatlab.cmake

#=============================================================================
# Copyright 2005-2009 Kitware, Inc.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

SET(MATLAB_FOUND 0)
IF(WIN32)
  # Search for a version of Matlab available, starting from the most modern one to older versions
  FOREACH(MATVER "8.0" "7.20" "7.19" "7.18" "7.17" "7.16" "7.15" "7.14" "7.13" "7.12" "7.11" "7.10" "7.9" "7.8" "7.7" "7.6" "7.5" "7.4")
    IF((NOT DEFINED MATLAB_ROOT) 
        OR ("${MATLAB_ROOT}" STREQUAL "")
        OR ("${MATLAB_ROOT}" STREQUAL "/registry"))
      GET_FILENAME_COMPONENT(MATLAB_ROOT
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\${MATVER};MATLABROOT]"
        ABSOLUTE)
      SET(MATLAB_VERSION ${MATVER})
    ENDIF((NOT DEFINED MATLAB_ROOT) 
      OR ("${MATLAB_ROOT}" STREQUAL "")
      OR ("${MATLAB_ROOT}" STREQUAL "/registry"))
  ENDFOREACH(MATVER)
  
  # Directory name depending on whether the Windows architecture is 32
  # bit or 64 bit
  if(EXISTS "${MATLAB_ROOT}/extern/lib/win64/microsoft")
	set(WINDIR "win64")
  elseif(EXISTS "${MATLAB_ROOT}/extern/lib/win32/microsoft")
	set(WINDIR "win32")
  else(EXISTS "${MATLAB_ROOT}/extern/lib/win64/microsoft")
	message(FATAL_ERROR "Could not find whether Matlab is 32 bit or 64 bit")
  endif(EXISTS "${MATLAB_ROOT}/extern/lib/win64/microsoft")

  # Folder where the MEX libraries are, depending on the Windows compiler
  IF(${CMAKE_GENERATOR} MATCHES "Visual Studio 6")
    SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/msvc60")
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 7")
    # Assume people are generally using Visual Studio 7.1,
    # if using 7.0 need to link to: ../extern/lib/${WINDIR}/microsoft/msvc70
    SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/msvc71")
    # SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/msvc70")
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Borland")
    # Assume people are generally using Borland 5.4,
    # if using 7.0 need to link to: ../extern/lib/${WINDIR}/microsoft/msvc70
    SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/bcc54")
    # SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/bcc50")
    # SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/bcc51")
  ELSEIF(${CMAKE_GENERATOR} MATCHES "Visual Studio*")
    # If the compiler is Visual Studio, but not any of the specific
    # versions above, we try our luck with the microsoft directory
    SET(MATLAB_LIBRARIES_DIR "${MATLAB_ROOT}/extern/lib/${WINDIR}/microsoft/")
  ELSE(${CMAKE_GENERATOR} MATCHES "Visual Studio 6")
    MESSAGE(FATAL_ERROR "Generator not compatible: ${CMAKE_GENERATOR}")
  ENDIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 6")

  # Get paths to the Matlab MEX libraries
  FIND_LIBRARY(MATLAB_MEX_LIBRARY
    libmex
    ${MATLAB_LIBRARIES_DIR}
    )
  FIND_LIBRARY(MATLAB_MX_LIBRARY
    libmx
    ${MATLAB_LIBRARIES_DIR}
    )
  FIND_LIBRARY(MATLAB_ENG_LIBRARY
    libeng
    ${MATLAB_LIBRARIES_DIR}
    )
  FIND_LIBRARY(MATLAB_UT_LIBRARY
    libut
    ${MATLAB_LIBRARIES_DIR}
    )

  # Get path to the include directory
  FIND_PATH(MATLAB_INCLUDE_DIR
    "mex.h"
    "${MATLAB_ROOT}/extern/include"
    )

ELSE(WIN32)

  IF((NOT DEFINED MATLAB_ROOT) 
      OR ("${MATLAB_ROOT}" STREQUAL ""))
    # check that command "matlab" is in the path
    execute_process(
      COMMAND which matlab
      OUTPUT_VARIABLE MATLAB_ROOT
      )
    if("${MATLAB_ROOT}" STREQUAL "")
      message(FATAL_ERROR "MATLAB_ROOT variable not provider by the user, and 'matlab' command not in the path either. I do not know where to search for Matlab.")
    endif()

    # get path to the Matlab root directory
    execute_process(
      COMMAND which matlab
      COMMAND xargs readlink -m
      COMMAND xargs dirname
      COMMAND xargs dirname
      COMMAND xargs echo -n
      OUTPUT_VARIABLE MATLAB_ROOT
      )
  ENDIF((NOT DEFINED MATLAB_ROOT) OR ("${MATLAB_ROOT}" STREQUAL ""))

  # search for the Matlab binary in the Matlab root directory
  find_program(
    MATLAB_BINARY
    matlab
    PATHS "${MATLAB_ROOT}/bin"
    )
  if(NOT MATLAB_BINARY)
    message(FATAL_ERROR "Matlab binary 'matlab' is not in the path, and I could not find it in ${MATLAB_ROOT}/bin either")
  endif(NOT MATLAB_BINARY)
    
  # Get Matlab version
  EXECUTE_PROCESS(
    COMMAND "${MATLAB_BINARY}" -nosplash -nodesktop -nojvm -r "version, exit"
    COMMAND grep ans -A 2
    COMMAND tail -n 1
    COMMAND awk "{print $2}"
    COMMAND tr -d "()"
    COMMAND xargs echo -n
    OUTPUT_VARIABLE MATLAB_VERSION
    )
	#MESSAGE("VER: ${MATLAB_VERSION}")

  # get mex extension
  EXECUTE_PROCESS(
    COMMAND ${MATLAB_ROOT}/bin/mexext
    COMMAND xargs echo -n
	OUTPUT_VARIABLE MATLAB_SUFFIX
    )
  #MESSAGE("MEXEXT: ${MATLAB_SUFFIX}")

  # Check if this is a Mac
  IF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

    SET(LIBRARY_EXTENSION .dylib)

    # If this is a Mac and the attempts to find MATLAB_ROOT have so far failed, 
    # we look in the applications folder
    IF((NOT DEFINED MATLAB_ROOT) OR ("${MATLAB_ROOT}" STREQUAL ""))

    # Search for a version of Matlab available, starting from the most modern one to older versions
      FOREACH(MATVER "R2013b" "R2013a" "R2012b" "R2012a" "R2011b" "R2011a" "R2010b" "R2010a" "R2009b" "R2009a" "R2008b")
        IF((NOT DEFINED MATLAB_ROOT) OR ("${MATLAB_ROOT}" STREQUAL ""))
          IF(EXISTS /Applications/MATLAB_${MATVER}.app)
            SET(MATLAB_ROOT /Applications/MATLAB_${MATVER}.app)
    
          ENDIF(EXISTS /Applications/MATLAB_${MATVER}.app)
        ENDIF((NOT DEFINED MATLAB_ROOT) OR ("${MATLAB_ROOT}" STREQUAL ""))
      ENDFOREACH(MATVER)

    ENDIF((NOT DEFINED MATLAB_ROOT) OR ("${MATLAB_ROOT}" STREQUAL ""))

  ELSE(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    SET(LIBRARY_EXTENSION .so)

  ENDIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

  # Get path to the MEX libraries
#  EXECUTE_PROCESS(
#    COMMAND find "${MATLAB_ROOT}/bin" -name libmex${LIBRARY_EXTENSION}
#    COMMAND xargs echo -n
#    OUTPUT_VARIABLE MATLAB_MEX_LIBRARY
#    )
#  EXECUTE_PROCESS(
#    COMMAND find "${MATLAB_ROOT}/bin" -name libmx${LIBRARY_EXTENSION}
#    COMMAND xargs echo -n
#    OUTPUT_VARIABLE MATLAB_MX_LIBRARY
#    )
#  EXECUTE_PROCESS(
#    COMMAND find "${MATLAB_ROOT}/bin" -name libeng${LIBRARY_EXTENSION}
#    COMMAND xargs echo -n
#    OUTPUT_VARIABLE MATLAB_ENG_LIBRARY
#    )
#  EXECUTE_PROCESS(
#    COMMAND find "${MATLAB_ROOT}/bin" -name libut${LIBRARY_EXTENSION}
#    COMMAND xargs echo -n
#    OUTPUT_VARIABLE MATLAB_UT_LIBRARY
#    )

  FIND_LIBRARY(MATLAB_MEX_LIBRARY mex PATHS ${MATLAB_ROOT}/bin PATH_SUFFIXES glnx86 glnxa64 NO_DEFAULT_PATH)
  FIND_LIBRARY(MATLAB_MX_LIBRARY mx PATHS ${MATLAB_ROOT}/bin PATH_SUFFIXES glnx86 glnxa64 NO_DEFAULT_PATH)
  FIND_LIBRARY(MATLAB_ENG_LIBRARY eng PATHS ${MATLAB_ROOT}/bin PATH_SUFFIXES glnx86 glnxa64 NO_DEFAULT_PATH)
  FIND_LIBRARY(MATLAB_UT_LIBRARY ut PATHS ${MATLAB_ROOT}/bin PATH_SUFFIXES glnx86 glnxa64 NO_DEFAULT_PATH)

  # Get path to the include directory
  FIND_PATH(MATLAB_INCLUDE_DIR
    "mex.h"
    PATHS "${MATLAB_ROOT}/extern/include"
    )

ENDIF(WIN32)

# This is common to UNIX and Win32:
SET(MATLAB_LIBRARIES
  ${MATLAB_MEX_LIBRARY}
  ${MATLAB_MX_LIBRARY}
  ${MATLAB_ENG_LIBRARY}
  ${MATLAB_UT_LIBRARY}
)

#IF(MATLAB_INCLUDE_DIR AND MATLAB_LIBRARIES)
#  SET(MATLAB_FOUND 1)
#ENDIF(MATLAB_INCLUDE_DIR AND MATLAB_LIBRARIES)

# According to http://www.cmake.org/Wiki/CMake:How_To_Find_Libraries:
#  Set <name>_INCLUDE_DIRS to <name>_INCLUDE_DIR <dependency1>_INCLUDE_DIRS ...
SET (MATLAB_INCLUDE_DIRS ${MATLAB_INCLUDE_DIR})

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Matlab DEFAULT_MSG MATLAB_LIBRARIES MATLAB_INCLUDE_DIRS MATLAB_SUFFIX)

MARK_AS_ADVANCED(
  MATLAB_LIBRARIES
  MATLAB_MEX_LIBRARY
  MATLAB_MX_LIBRARY
  MATLAB_ENG_LIBRARY
  MATLAB_UT_LIBRARY
  MATLAB_INCLUDE_DIRS
  MATLAB_FOUND
  MATLAB_ROOT
  MATLAB_VERSION
  MATLAB_SUFFIX
)

#IF (MATLAB_FOUND)
#	MESSAGE(FOUND IT)
#	MESSAGE("LIBS: ${MATLAB_LIBRARIES}")
#	MESSAGE("MATLAB SUFFIX: ${MATLAB_SUFFIX}")
#ENDIF (MATLAB_FOUND)
