#!/bin/bash

# Tested on Apple Silicon Mac, with cmake 3.19.2.

pwd=$(pwd)
prefix=$pwd
#sysroot=iphoneos
sysroot=iphonesimulator


# Install directory for all dependencies
mkdir -p $prefix

 # Boost
 echo "wget boost..."
 curl -L https://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz -o boost_1_59_0.tar.gz
 tar -xzf boost_1_59_0.tar.gz
 cd boost_1_59_0
 curl -L https://gist.github.com/matlabbe/0bce8feeb73a499a76afbbcc5c687221/raw/489ff2869eccd6f8d03ffb9090ef839108762741/BoostConfig.cmake.in -o BoostConfig.cmake.in
 curl -L https://gist.github.com/matlabbe/0bce8feeb73a499a76afbbcc5c687221/raw/b07fe7d4e5dfe5f1d110c733e5cf660d79a26378/CMakeLists.txt -o CMakeLists.txt
 mkdir build
 cd build
 cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_INSTALL_PREFIX=$prefix ..
 cmake --build . --config Release
 cmake --build . --config Release --target install
 cd $pwd
 #rm -r boost_1_59_0.tar.gz
 ##
 # eigen
 echo "wget eigen..."
 curl -L https://gitlab.com/libeigen/eigen/-/archive/3.3.9/eigen-3.3.9.tar.gz -o 3.3.9.tar.gz
 tar -xzf 3.3.9.tar.gz
 cd eigen-3.3.9
 mkdir build
 cd build
 cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_INSTALL_PREFIX=$prefix ..
 cmake --build . --config Release
 cmake --build . --config Release --target install
 cd $pwd
 #rm -r 3.3.9.tar.gz eigen-3.3.9
 #
 # FLANN
 echo "wget flann..."
 git clone https://github.com/flann-lib/flann.git
 cd flann
 git checkout 1.8.4
 curl -L https://gist.githubusercontent.com/matlabbe/c858ba36fb85d5e44d8667dfb3543e12/raw/8fc40aa9bc3267604869444020476a49f14ab424/flann_ios.patch  -o flann_ios.patch
 git apply flann_ios.patch
 mkdir build
 cd build
 # comment "add_subdirectory( test )" in top CMakeLists.txt
 # comment "add_subdirectory( doc )" in top CMakeLists.txt
 cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_INSTALL_PREFIX=$prefix -DBUILD_PYTHON_BINDINGS=OFF -DBUILD_MATLAB_BINDINGS=OFF -DBUILD_C_BINDINGS=OFF  ..
 cmake --build . --config Release -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
 cmake --build . --config Release --target install -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
 cd $pwd
 #rm -r flann

 # !!! ORB use thirdparty g2o !!!
 # g2o
 echo "installing g2o..."
 cd g2o
 rm -rf build
 mkdir build
 cd build
 cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_INSTALL_PREFIX=$prefix -DBUILD_LGPL_SHARED_LIBS=OFF -DG2O_BUILD_APPS=OFF -DG2O_BUILD_EXAMPLES=OFF -DCMAKE_FIND_ROOT_PATH=$prefix ..
 cmake --build . --config Release -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
 cmake --build . --config Release --target install -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
 cd $pwd
 #rm -rf g2o
#
# VTK
git clone https://github.com/Kitware/VTK.git
cd VTK
git checkout tags/v8.2.0
git cherry-pick bf3ae8072df2393c7270509bae41be0776826346
mkdir build
cd build

# set different arch for simulator and device based on sysroot
if [[ $sysroot == "iphonesimulator" ]]; then
    echo "sysroot is iphonesimulator"
    cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_FRAMEWORK_INSTALL_PREFIX=$prefix/lib -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DVTK_IOS_BUILD=ON -DIOS_SIMULATOR_ARCHITECTURES=arm64 -DIOS_DEVICE_ARCHITECTURES="" -DModule_vtkFiltersModeling=ON ..
elif [[ $sysroot == "iphoneos" ]]; then
    echo "sysroot is iphoneos"
    cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_FRAMEWORK_INSTALL_PREFIX=$prefix/lib -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DVTK_IOS_BUILD=ON -DModule_vtkFiltersModeling=ON ..
else
    echo "sysroot is not iphoneos or iphonesimulator"
    exit 1
fi
cmake --build . --config Release
cd $pwd
#rm -rf VTK

# PCL
git clone https://github.com/PointCloudLibrary/pcl.git
cd pcl
git checkout tags/pcl-1.11.1
# patch
curl -L https://gist.github.com/matlabbe/f3ba9366eb91e1b855dadd2ddce5746d/raw/4a66ebb9faa1dfe997a0860d733bc5473cff20ee/pcl_1_11_1_vtk_ios_support.patch -o pcl_1_11_1_vtk_ios_support.patch
git apply pcl_1_11_1_vtk_ios_support.patch
mkdir build
cd build
cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_INSTALL_PREFIX=$prefix -DBUILD_apps=OFF -DBUILD_examples=OFF -DBUILD_tools=OFF -DBUILD_visualization=OFF -DBUILD_tracking=OFF -DBUILD_people=OFF -DBUILD_global_tests=OFF -DWITH_QT=OFF -DWITH_OPENGL=OFF -DWITH_VTK=ON -DPCL_SHARED_LIBS=OFF -DCMAKE_FIND_ROOT_PATH=$prefix ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd $pwd
#rm -rf pcl
#
# OpenCV
git clone https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout tags/3.4.2
cd $pwd
git clone https://github.com/opencv/opencv.git
cd opencv
git checkout tags/3.4.2
curl -L https://gist.githubusercontent.com/matlabbe/fdc3ab4854f3a68fbde7277f543b4e5b/raw/f340839c09165056d3845645df24b76507542fd2/opencv_ios.patch -o opencv_ios.patch
git apply opencv_ios.patch
mkdir build
cd build
# add "add_definitions(-DPNG_ARM_NEON_OPT=0)" in 3rdparty/libpng/CMakeLists.txt
cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_INSTALL_PREFIX=$prefix -DOPENCV_EXTRA_MODULES_PATH=$prefix/opencv_contrib/modules -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DWITH_CUDA=OFF -DBUILD_opencv_apps=OFF -DBUILD_opencv_xobjdetect=OFF -DBUILD_opencv_stereo=OFF ..
cmake --build . --config Release
cmake --build . --config Release --target install
cd $pwd
#rm -rf opencv opencv_contrib

# DBoW2
cd DBoW2

rm -rf build
mkdir build
cd build
cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_FIND_ROOT_PATH=$prefix -DCMAKE_INSTALL_PREFIX=$prefix ..
cmake --build . --config Release -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
cmake --build . --config Release --target install -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
cd $pwd

# Sophus
cd Sophus

rm -rf build
mkdir build
cd build
cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_FIND_ROOT_PATH=$prefix -DCMAKE_INSTALL_PREFIX=$prefix ..
cmake --build . --config Release -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
cmake --build . --config Release --target install -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
cd $pwd


# ORBSLAM3
cd ORB_SLAM3_DenseMap

rm -rf build
mkdir build
cd build
cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_SYSROOT=$sysroot -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DCMAKE_FIND_ROOT_PATH=$prefix -DCMAKE_INSTALL_PREFIX=$prefix ..
cmake --build . --config Release -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
cmake --build . --config Release --target install -- CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_ENTITLEMENTS=""  CODE_SIGNING_ALLOWED="NO"
cd $pwd
