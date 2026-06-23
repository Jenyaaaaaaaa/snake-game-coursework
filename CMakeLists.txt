cmake_minimum_required(VERSION 3.16)

project(Snake VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)

qt_standard_project_setup(REQUIRES 6.10)

# Автоматично компілюємо resources.qrc
set(CMAKE_AUTORCC ON)

qt_add_executable(appSnake
    main.cpp
    gamecontroller.h
    gamecontroller.cpp
    resources.qrc
)

qt_add_qml_module(appSnake
    URI Snake
    VERSION 1.0
    QML_FILES
        Main.qml
        GameButton.qml
        MainMenu.qml
        GameScene.qml
        DigitDisplay.qml
)

set_target_properties(appSnake PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSnake
    PRIVATE Qt6::Quick Qt6::Multimedia
)

install(TARGETS appSnake
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)