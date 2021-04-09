if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

set(VERSION 1.3.9)
set(SCONS_VERSION 4.1.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/serf/serf-${VERSION}.tar.bz2"
    FILENAME "serf-${VERSION}.tar.bz2"
    SHA512 9f5418d991840a08d293d1ecba70cd9534a207696d002f22dbe62354e7b005955112a0d144a76c89c7f7ad3b4c882e54974441fafa0c09c4aa25c49c021ca75d
)

vcpkg_download_distfile(SCONS_ARCHIVE
    URLS "https://prdownloads.sourceforge.net/scons/scons-local-${SCONS_VERSION}.tar.gz"
    FILENAME "scons-local-${SCONS_VERSION}.tar.gz"
    SHA512 e52da08dbd4e451ec76f0b45547880a3e2fbd19b07a16b1cc9c0525f09211162ef59ff1ff49fd76d323e1e2a612ebbafb646710339569677e14193d49c8ebaeb
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        SConstruct-python3.patch
)

# Obtain the SCons buildmanager, for setting up the build
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SCONS_PATH
    ARCHIVE ${SCONS_ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_build_process(
    COMMAND ${PYTHON3} ${SCONS_PATH}/scons.py PREFIX=install LIBDIR=install/lib OPENSSL=${CURRENT_INSTALLED_DIR} ZLIB=${CURRENT_INSTALLED_DIR} APR=${CURRENT_INSTALLED_DIR} APU=${CURRENT_INSTALLED_DIR} SOURCE_LAYOUT=no APR_STATIC=yes install-lib install-inc
    WORKING_DIRECTORY ${SOURCE_PATH}
)