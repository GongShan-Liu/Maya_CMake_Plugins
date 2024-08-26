# 搜索maya模块

# 设置初始化变量
# set(MAYA_VERSION 2018 CACHE STRING "Maya Version") # 设置maya版本
set(MAYA_INSTALL_PATH_SUFFIX "")
set(MAYA_LIB_DIR_NAME "lib")
set(MAYA_INCLUDE_DIR_NAME "include")
set(MAYA_COMPILE_DEFINITIONS "REQUIRED_IOSTREAM; _BOOL")
set(MAYA_TARGET_TYPE LIBRARY)

# 设置构建各个平台的变量参数
if (WIN32)
	# Maya Windows
    set(MAYA_INSTALL_PATH "C:/Program Files/Autodesk") # maya安装路径
    set(MAYA_PLUGIN_EXTENSION ".mll") # 扩展插件
    set(OPENMAYA OpenMaya.lib)

    # 编译
	set(MAYA_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS};NT_PLUGIN;_MBCS;_AFXDLL") # 预处理器定义
	set(MAYA_TARGET_TYPE RUNTIME)

elseif(APPLE)
	# Apple Maya
    set(MAYA_INSTALL_PATH /Applications/Autodesk)
    set(MAYA_LIB_DIR_NAME "Maya.app/Contents/MacOS")
    set(MAYA_PLUGIN_EXTENSION ".bundle")
    set(OPENMAYA libOpenMaya.dylib)

    # 编译
	set(MAYA_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS};OSMac_;_DARWIN;MAC_PLUGIN;OSMac_MachO;OSMacOSX_;CC_GNU_;_LANGUAGE_C_PLUS_PLUS")
    
else()
	# Maya Linux
    set(MAYA_INSTALL_PATH /usr/autodesk)
    set(MAYA_PLUGIN_EXTENSION ".so")
    set(OPENMAYA libOpenMaya.so)
    if(MAYA_VERSION LESS 2016)
        SET(MAYA_INSTALL_PATH_SUFFIX -x64)
    endif()

    # 编译
    set(MAYA_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS};LINUX;_LINUX;LINUX_64") 
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")  #compiler flags += -fPIC
    
endif()

# SDK路径
get_filename_component(MAYA_BUILD_ENV ${CMAKE_MODULE_PATH} DIRECTORY) # 获取maya插件文件夹的根目录
set(MAYA_SDK_LOCATION ${MAYA_BUILD_ENV}/SDK/${MAYA_SDK_PACKAGE_NAME}/devkitBase)
message("[Log] Maya SDK location: ${MAYA_SDK_LOCATION}")

# Maya安装路径
set(MAYA_INSTALL_PATH ${MAYA_INSTALL_PATH} CACHE STRING "Maya installation path")
set(MAYA_LOCATION ${MAYA_INSTALL_PATH}/Maya${MAYA_VERSION}${MAYA_INSTALL_PATH_SUFFIX}) 
message("[Log] Maya installation location: ${MAYA_LOCATION}")

# 在SDK查找头文件并返回目录
find_path(	MAYA_INCLUDE_DIR 	maya/MFn.h
			PATHS 				${MAYA_SDK_LOCATION} 
			PATH_SUFFIXES 		"${MAYA_INCLUDE_DIR_NAME}/"
			DOC					"Maya Include Path"
)
message("[Log] Maya include location:  ${MAYA_INCLUDE_DIR}")

# 在Maya安装路径查找头文件并返回目录
#Find libs in maya installation folder and return a dirrectory
find_path(  MAYA_LIBRARY_DIR    ${OPENMAYA}
            PATHS               ${MAYA_LOCATION}
            PATH_SUFFIXES       "${MAYA_LIB_DIR_NAME}/"
            DOC                 "Maya Library Path"
)
message("[Log] Maya libs location: ${MAYA_LIBRARY_DIR}")

# 查找maya api每个模块的库路径
foreach(MAYA_LIB OpenMaya OpenMayaAnim OpenMayaFX OpenMayaRender OpenMayaUI Foundation)
	find_library(MAYA_${MAYA_LIB}_LIBRARY NAMES ${MAYA_LIB} PATHS ${MAYA_LIBRARY_DIR} NO_DEFAULT_PATH)
	set(MAYA_LIBRARIES ${MAYA_LIBRARIES} ${MAYA_${MAYA_LIB}_LIBRARY}) #append a lib to MAYA_LIBRARIES list
endforeach()

# 为苹果平台指定 "Clang" 编译器特定标志
# -std=c++0x : 设置c+版本
# -stdlib=libstdc++   - 指定"Clang"使用标准Gcc的c+库
if (APPLE AND ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang") 
    set(MAYA_CXX_FLAGS "-std=c++0x -stdlib=libstdc++")
endif()

# 如果未定义MAYA_INCLUDE_DIR、MAYA_LIBRARY_DIR和MAYA_LIBRIES，则显示错误
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Maya DEFAULT_MSG MAYA_INCLUDE_DIR MAYA_LIBRARY_DIR MAYA_LIBRARIES)

# 通过循环设置每个编译选项 (_target)
function(MAYA_PLUGIN _target)

    # 特定于平台的预处理器选项
    if (WIN32)
        set_target_properties(${_target} PROPERTIES
            LINK_FLAGS "/export:initializePlugin /export:uninitializePlugin"
            COMPILE_FLAGS "/MD"
        )
    endif()

    # 公共选项
    set_target_properties(${_target} PROPERTIES
        COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS}"
        PREFIX ""
        SUFFIX ${MAYA_PLUGIN_EXTENSION}
    )
    
endfunction()


