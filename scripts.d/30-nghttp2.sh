#!/bin/bash

SCRIPT_REPO="https://github.com/nghttp2/nghttp2.git"
SCRIPT_COMMIT="v1.64.0"
SCRIPT_TAGFILTER="v*"

ffbuild_depends() {
    echo base
    echo openssl
    echo zlib
}

ffbuild_enabled() {
    # Only enable for Linux targets
    [[ $TARGET == linux* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_STATIC_LIBS=ON \
        -DENABLE_LIB_ONLY=ON \
        -DENABLE_DOC=OFF \
        ..

    ninja -j$(nproc)
    DESTDIR="$FFBUILD_DESTDIR" ninja install

    # Add private dependencies for static linking
    {
        echo "Requires.private: libssl libcrypto zlib"
    } >> "$FFBUILD_DESTPREFIX"/lib/pkgconfig/libnghttp2.pc
}

ffbuild_configure() {
    [[ $TARGET == linux* ]] || return 0
    echo --enable-libnghttp2
}

ffbuild_unconfigure() {
    echo --disable-libnghttp2
}
