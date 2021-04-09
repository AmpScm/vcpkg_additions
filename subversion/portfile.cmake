if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

set(VERSION 1.14.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.apache.org/dist/subversion/subversion-${VERSION}.tar.bz2"
    FILENAME "subversion-${VERSION}.tar.bz2"
    SHA512 0a70c7152b77cdbcb810a029263e4b3240b6ef41d1c19714e793594088d3cca758d40dfbc05622a806b06463becb73207df249393924ce591026b749b875fcdd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        fix-libserf.patch
)

vcpkg_find_acquire_program(PYTHON3)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  set(MSBUILD_PLATFORM x64)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
  set(MSBUILD_PLATFORM Win32)
else()
  message(FATAL_ERROR "${PORT} does not currently support this platform")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BUILD_MODE "--with-shared-serf")
else()
  set(BUILD_MODE "--with-static-apr --with-static-openssl --disable-shared")
endif()

# ### TODO: Maybe add
# --with-httpd=${CURRENT_INSTALLED_DIR} # For mod_dav_svn (requires Apache HTTPD)
# --with-sasl=${CURRENT_INSTALLED_DIR} # For sasls in svn:// (requires Cyrus Sasl)

vcpkg_execute_build_process(
    COMMAND ${PYTHON3} gen-make.py
        -t vcproj --vsnet-version=2019 # Actual version is overridden during MSBuild step.
        --with-apr=${CURRENT_INSTALLED_DIR}
        --with-apr-util=${CURRENT_INSTALLED_DIR}
        --with-openssl=${CURRENT_INSTALLED_DIR}
        --with-serf=${CURRENT_INSTALLED_DIR}
        --with-sqlite=${CURRENT_INSTALLED_DIR}
        --with-zlib=${CURRENT_INSTALLED_DIR}
        ${BUILD_MODE}
        -D SVN_HI_RES_SLEEP_MS=1
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/subversion_vcnet.sln
    TARGET __ALL__
    PLATFORM ${MSBUILD_PLATFORM}
    USE_VCPKG_INTEGRATION
)