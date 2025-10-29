cmake_minimum_required(VERSION 3.16)

project(smu_mini_qt VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core SerialPort)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appsmu_mini_qt
    main.cpp
)

qt_add_qml_module(appsmu_mini_qt
    URI smu_mini_qt
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES myserialport.h myserialport.cpp
        QML_FILES SmuSetFunction.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appsmu_mini_qt PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appsmu_mini_qt
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appsmu_mini_qt
    PRIVATE Qt6::Quick
)
target_link_libraries(appsmu_mini_qt PRIVATE Qt6::Core Qt6::SerialPort)

include(GNUInstallDirs)
install(TARGETS appsmu_mini_qt
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
