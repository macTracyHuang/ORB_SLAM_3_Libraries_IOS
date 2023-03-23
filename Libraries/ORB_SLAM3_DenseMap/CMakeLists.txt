cmake_minimum_required(VERSION 2.8)
project(ORB_SLAM3)

add_definitions(-w)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF()

MESSAGE("Build type: " ${CMAKE_BUILD_TYPE})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -Wall  -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall  -O3")

# Check C++11 or C++0x support
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
   add_definitions(-DCOMPILEDWITHC11)
   message(STATUS "Using flag -std=c++11.")
elseif(COMPILER_SUPPORTS_CXX0X)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
   add_definitions(-DCOMPILEDWITHC0X)
   message(STATUS "Using flag -std=c++0x.")
else()
   message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake_modules)

# 要保证整个工程的opencv版本一致，包括dbow，源码以及ros相关的
# 3 4 都可以正常运行
find_package(OpenCV 3.2)
   if(NOT OpenCV_FOUND)
      message(FATAL_ERROR "OpenCV > 3.2 not found.")
   endif()

MESSAGE("OPENCV VERSION:")
MESSAGE(${OpenCV_VERSION})

find_package(Eigen3 3.1.0 REQUIRED)
find_package(PCL 1.11 REQUIRED)

# Link Boost
set(Boost_USE_STATIC_LIBS        ON) # only find static libs
set(Boost_USE_MULTITHREADED      ON)
set(Boost_USE_STATIC_RUNTIME    OFF)
find_package(Boost 1.59 QUIET)
if(Boost_FOUND)
    MESSAGE("=========Boost_FOUND=========")
endif()


include_directories(
${PROJECT_SOURCE_DIR}
${PROJECT_SOURCE_DIR}/include
${PROJECT_SOURCE_DIR}/include/CameraModels
${CMAKE_INSTALL_PREFIX}/include/sophus
${EIGEN3_INCLUDE_DIR}
${PCL_INCLUDE_DIRS}
${Boost_INCLUDE_DIRS}
)
MESSAGE("PCL_INCLUDE_DIRS")
MESSAGE(${PCL_INCLUDE_DIRS})
MESSAGE("PCL_LIBRARY_DIRS")
MESSAGE(${PCL_LIBRARY_DIRS})
add_definitions( ${PCL_DEFINITIONS} )
link_directories( ${PCL_LIBRARY_DIRS} )

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib)

set(HDRS_CM
   include/CameraModels/GeometricCamera.h
   include/CameraModels/Pinhole.h
   include/CameraModels/KannalaBrandt8.h
)

set(HDRS_ORBSLAM
   include/System.h
   include/Tracking.h
   include/LocalMapping.h
   include/LoopClosing.h
   include/ORBextractor.h
   include/ORBmatcher.h
   include/FrameDrawer.h
   include/Converter.h
   include/MapPoint.h
   include/KeyFrame.h
   include/Atlas.h
   include/Map.h
   include/MapDrawer.h
   include/Optimizer.h
   include/Frame.h
   include/KeyFrameDatabase.h
   include/Sim3Solver.h
   include/Viewer.h
   include/ImuTypes.h
   include/G2oTypes.h
   include/OptimizableTypes.h
   include/MLPnPsolver.h
   include/GeometricTools.h
   include/TwoViewReconstruction.h
   include/SerializationUtils.h
   include/Config.h
   include/Settings.h
   include/ORBVocabulary.h
   include/PointCloudMapping.h
)

set(SRCS_ORBSLAM
   src/System.cc
   src/Tracking.cc
   src/LocalMapping.cc
   src/LoopClosing.cc
   src/ORBextractor.cc
   src/ORBmatcher.cc
   src/FrameDrawer.cc
   src/Converter.cc
   src/MapPoint.cc
   src/KeyFrame.cc
   src/Atlas.cc
   src/Map.cc
   src/MapDrawer.cc
   src/Optimizer.cc
   src/Frame.cc
   src/KeyFrameDatabase.cc
   src/Sim3Solver.cc
   src/Viewer.cc
   src/ImuTypes.cc
   src/G2oTypes.cc
   src/CameraModels/Pinhole.cpp
   src/CameraModels/KannalaBrandt8.cpp
   src/OptimizableTypes.cpp
   src/MLPnPsolver.cpp
   src/GeometricTools.cc
   src/TwoViewReconstruction.cc
   src/Config.cc
   src/Settings.cc
   src/PointCloudMapping.cc
)

add_library(${PROJECT_NAME} STATIC
   ${SRCS_ORBSLAM}
   ${HDRS_ORBSLAM}
)


target_link_libraries(${PROJECT_NAME}
${OpenCV_LIBS}
${EIGEN3_LIBS}
${Pangolin_LIBRARIES}
# ${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
# ${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
${CMAKE_INSTALL_PREFIX}/lib
${PCL_LIBRARIES}
${Boost_LIBRARIES}
# -lboost_serialization
# -lcrypto
)

# Install Stuff
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
install(FILES ${HDRS_ORBSLAM} ${HDRS_CM} DESTINATION ${CMAKE_INSTALL_PREFIX}/include/${PROJECT_NAME})
# install(FILES ${HDRS_CM} DESTINATION ${CMAKE_INSTALL_PREFIX}/include/${PROJECT_NAME}/CameraModels)
