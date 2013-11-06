# - Find libconfig
# Find the native libconfig includes and library
#
# LIBCONFIG_INCLUDE_DIRS - where to find libconfig.h
# LIBCONFIG_LIBRARIES - List of libraries when using libconfig.
# LIBCONFIG_FOUND - True if libconfig found.
#
#  stolen from: http://code.google.com/p/keritzel/source/browse/branches/emulador/3rdparty/cmake/FindLIBCONFIG.cmake?r=9
#
#  22.01.13: modified by pwohlhart 
#    * to prefer a user defined path if given
#    * to include config++
#


find_path( LIBCONFIG_INCLUDE_DIR libconfig.h
	PATHS "${LIBCONFIG_ROOT}/include" "/usr/include" "/usr/local/include" 
)

find_path( LIBCONFIGPP_INCLUDE_DIR libconfig.h++
	PATHS "${LIBCONFIG_ROOT}/include" "/usr/include" "/usr/local/include" 
)

find_library( LIBCONFIG_LIBRARY NAMES libconfig config
	PATHS "${LIBCONFIG_ROOT}/lib" "/usr/lib" "/usr/local/lib" 
)

find_library( LIBCONFIGPP_LIBRARY NAMES libconfig++ config++
	PATHS "${LIBCONFIG_ROOT}/lib" "/usr/lib" "/usr/local/lib" 
)

mark_as_advanced( LIBCONFIG_LIBRARY LIBCONFIG_INCLUDE_DIR  LIBCONFIGPP_LIBRARY LIBCONFIGPP_INCLUDE_DIR )

if( LIBCONFIG_INCLUDE_DIR AND EXISTS "${LIBCONFIG_INCLUDE_DIR}/libconfig.h" )
file( STRINGS "${LIBCONFIG_INCLUDE_DIR}/libconfig.h" LIBCONFIG_H REGEX "^#define[ \t]+LIBCONFIG_VER_M[A-Z]+[ \t]+[0-9]+.*$" )
string( REGEX REPLACE "^.*LIBCONFIG_VER_MAJOR[ \t]+([0-9]+).*$" "\\1" LIBCONFIG_MAJOR "${LIBCONFIG_H}" )
string( REGEX REPLACE "^.*LIBCONFIG_VER_MINOR[ \t]+([0-9]+).*$" "\\1" LIBCONFIG_MINOR "${LIBCONFIG_H}" )

set( LIBCONFIG_VERSION_STRING "${LIBCONFIG_MAJOR}.${LIBCONFIG_MINOR}" )
set( LIBCONFIG_VERSION_MAJOR "${LIBCONFIG_MAJOR}" )
set( LIBCONFIG_VERSION_MINOR "${LIBCONFIG_MINOR}" )
endif()

# handle the QUIETLY and REQUIRED arguments and set LIBCONFIG_FOUND to TRUE if
# all listed variables are TRUE
include( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( LIBCONFIG
REQUIRED_VARS LIBCONFIG_LIBRARY LIBCONFIGPP_LIBRARY LIBCONFIG_INCLUDE_DIR LIBCONFIGPP_INCLUDE_DIR
LIBCONFIG_VERSION_MAJOR LIBCONFIG_VERSION_MINOR LIBCONFIG_VERSION_STRING )

if( LIBCONFIG_FOUND )
set( LIBCONFIG_LIBRARIES ${LIBCONFIG_LIBRARY} ${LIBCONFIGPP_LIBRARY} )
set( LIBCONFIG_INCLUDE_DIRS ${LIBCONFIG_INCLUDE_DIR} ${LIBCONFIGPP_INCLUDE_DIR} )
endif()
