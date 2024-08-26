# 设置项目名
project(helloWorldCmd)

# 获取当前文件夹中具有定义扩展名的所有文件
file(GLOB SRCS "*.cpp" "*.h")

# 指定头文件路径
include_directories(${MAYA_INCLUDE_DIR}) 

# 指定链接器路径
link_directories(${MAYA_LIBRARY_DIR}) # specifies a directory where a linker should search for libraries

# 指定动态库路径
add_library(${PROJECT_NAME} SHARED ${SRCS})

# 指定链接terget及其依赖项时要使用的库列表
target_link_libraries(${PROJECT_NAME} ${MAYA_LIBRARIES})

# 运行MAYA_PLUGIN函数
MAYA_PLUGIN(${PROJECT_NAME}) # runs a function with a PROJECT_NAME as an argument
