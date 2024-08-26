# 设置cmake版本
cmake_minimum_required(VERSION 3.30.2) 

# 系统变量可防止在 IDE 中生成 ZERO_CHECK 项目以及其他用户的自定义项目
set(CMAKE_SUPPRESS_REGENERATION true)

# 设置maya初始化变量
set(MAYA_VERSION 2018 CACHE STRING "Maya Version") # 设置maya版本
set(MAYA_SDK_PACKAGE_NAME Autodesk_Maya_2018_7_Update_DEVKIT_Windows CACHE STRING "Maya sdk package name")

# 设置输出的路径
if (WIN32)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_SOURCE_DIR}/plug-ins/Maya${MAYA_VERSION}) # 输出发布可执行文件
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_CURRENT_SOURCE_DIR}/plug-ins/Debug) # 输出debug可执行
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${CMAKE_CURRENT_SOURCE_DIR}/plug-ins/MinSizeRel) # MinSizeRel输出
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_CURRENT_SOURCE_DIR}/plug-ins/RelWithDebInfo) # RelWithDebInfo输出
else()
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/plug-ins) # 输出库
endif()

# 设置cmake的模块
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# 搜索maya包
find_package(Maya REQUIRED)

# 设置MAYA_SRCS变量
set(MAYA_PLUGINS_SRCS 
	helloWorldCmd 
	circle_test
	CACHE STRING "Maya Project")

# 把多个插件项目循环添加到cmake构建子目录
foreach(MAYA_PLUGINS_SRC ${MAYA_PLUGINS_SRCS})
	add_subdirectory(sources/${MAYA_PLUGINS_SRC})
endforeach()