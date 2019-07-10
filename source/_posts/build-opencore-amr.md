---
title: 编译opencore-amr for iOS8并支持bitcode
date: 2017-01-05 17:28:45
tags: [xcode, opencore-amr, amr, ios]
---

# 作用

`amr` 是一个很适合在线传输的音频格式。但悲摧的是`apple`早就不支持它了。原因不明。

另一层是微信也是使用的这种格式来录制音频。

不只`apple`不支持它，万能的`cocoapods`也没有支持的。只好自己动手了。

止于当前，我找到最合适的，就是`opencore-amr`库。这个库12年写就。这么多年也没见怎么更新。[捂脸]😂

找到了一个好心人写的支持`bitcode`和8.0的编译脚本

# 原料

github:[opencore-amr-IOS](https://github.com/feuvan/opencore-amr-iOS)

sourceforge:[opencore-amr 0.1.3](https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-0.1.3.tar.gz/download)

## 编译脚本
```bash
#!/bin/sh

set -xe

VERSION="0.1.3"
SDKVERSION="8.4"
LIBSRCNAME="opencore-amr"

CURRENTPATH=`pwd`

mkdir -p "${CURRENTPATH}/src"
tar zxvf ${LIBSRCNAME}-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/${LIBSRCNAME}-${VERSION}"

DEVELOPER=`xcode-select -print-path`
DEST="${CURRENTPATH}/lib-ios"
mkdir -p "${DEST}"

ARCHS="armv7 armv7s arm64 i386 x86_64"
# ARCHS="armv7"
LIBS="libopencore-amrnb.a libopencore-amrwb.a"

DEVELOPER=`xcode-select -print-path`

for arch in $ARCHS; do
case $arch in
arm*)

IOSV="-miphoneos-version-min=7.0"
if [ $arch == "arm64" ]
then
IOSV="-miphoneos-version-min=7.0"
fi

echo "Building for iOS $arch ****************"
SDKROOT="$(xcrun --sdk iphoneos --show-sdk-path)"
CC="$(xcrun --sdk iphoneos -f clang)"
CXX="$(xcrun --sdk iphoneos -f clang++)"
CPP="$(xcrun -sdk iphonesimulator -f clang++)"
CFLAGS="-isysroot $SDKROOT -arch $arch $IOSV -isystem $SDKROOT/usr/include -fembed-bitcode"
CXXFLAGS=$CFLAGS
CPPFLAGS=$CFLAGS
export CC CXX CFLAGS CXXFLAGS CPPFLAGS

./configure \
--host=arm-apple-darwin \
--prefix=$DEST \
--disable-shared --enable-static
;;
*)
IOSV="-mios-simulator-version-min=7.0"
echo "Building for iOS $arch*****************"

SDKROOT=`xcodebuild -version -sdk iphonesimulator Path`
CC="$(xcrun -sdk iphoneos -f clang)"
CXX="$(xcrun -sdk iphonesimulator -f clang++)"
CPP="$(xcrun -sdk iphonesimulator -f clang++)"
CFLAGS="-isysroot $SDKROOT -arch $arch $IOSV -isystem $SDKROOT/usr/include -fembed-bitcode"
CXXFLAGS=$CFLAGS
CPPFLAGS=$CFLAGS
export CC CXX CFLAGS CXXFLAGS CPPFLAGS
./configure \
--prefix=$DEST \
--disable-shared
;;
esac
make > /dev/null
make install
make clean
for i in $LIBS; do
mv $DEST/lib/$i $DEST/lib/$i.$arch
done
done

for i in $LIBS; do
input=""
for arch in $ARCHS; do
input="$input $DEST/lib/$i.$arch"
done
lipo -create -output $DEST/lib/$i $input
done
```
## 编译方式
```bash
> mkdir opencore-amr
> cd opencore-amr
> #把上方的脚本内容放到build.sh中。去下载0.1.3版的包，弄成下边的样子
> ls
build.sh				opencore-amr-0.1.3.tar.gz
> bash build.sh
> .....
> #完事后果子在：lib-ios文件夹中
> ls
  build.sh			lib-ios				opencore-amr-0.1.3.tar.gz	src
```
