import QtQuick
import QtQuick.Window
import QtCore
import Snake.Game
import QtMultimedia

Window {
    id: window

    visible: true
    title: "Snake"

    flags: Qt.Window | Qt.FramelessWindowHint

    color: "#151A14"

    //спільний масштаб усієї піксельної графіки
    property int pixelScale: 2

    //масштаб внутрішнього вмісту
    readonly property int contentScale: Math.max(
        2,
        Math.floor(
            Math.min(
                (window.width - window.sideBorderWidth * 2) / 320,
                (window.height
                 - window.titlebarHeight
                 - window.bottomBorderHeight) / 240
            )
        )
    )

    //розміри частин рамки
    readonly property int sideBorderWidth: 16 * pixelScale
    readonly property int titlebarHeight: 32 * pixelScale
    readonly property int bottomBorderHeight: 16 * pixelScale

    //внутр. обл. програми
    readonly property int contentBaseWidth: 320 * pixelScale
    readonly property int contentBaseHeight: 240 * pixelScale

    //повний розмір вікна разом із рамкою
    readonly property int baseWindowWidth:
        contentBaseWidth + sideBorderWidth * 2

    readonly property int baseWindowHeight:
        contentBaseHeight
        + titlebarHeight
        + bottomBorderHeight

    width: baseWindowWidth
    height: baseWindowHeight

    minimumWidth: baseWindowWidth
    minimumHeight: baseWindowHeight

    x: Math.round((Screen.width - width) / 2)
    y: Math.round((Screen.height - height) / 2)

    //поточний екран програми
    property string currentScreen: "menu"

    //нормальна складність за замовч.
    property string selectedDifficulty: "normal"

    //контролер з логікою
    GameController {
        id: gameController
    }

    Connections {
        target: gameController

        function onScoreChanged() {
            if (window.currentScreen === "game"
                    && gameController.score > window.previousScoreForSound) {
                window.playEatSound()
            }

            window.previousScoreForSound = gameController.score
        }

        function onPausedChanged() {
            if (window.currentScreen === "game" && gameController.paused)
                window.playPauseSound()
        }

        function onGameOverChanged() {
            if (gameController.gameOver) {
                window.updateHighScore()
                window.playGameOverSound()
            }
        }
    }

    //піксель шрифт
    FontLoader {
        id: pixelFont

        source: "qrc:/fonts/PressStart2P-Regular.ttf"

        onStatusChanged: {
            if (status === FontLoader.Ready)
                console.log("шрифт завантажено:", name)
            else if (status === FontLoader.Error)
                console.log("помилка завантаження шрифту")
        }
    }

    //запасний шрифт
    readonly property string pixelFontFamily:
        pixelFont.status === FontLoader.Ready
        ? pixelFont.name
        : "monospace"

    //налашт.
    Settings {
        id: applicationSettings

        category: "GameSettings"

        property bool musicEnabled: true
        property bool soundEnabled: true
        property string controlScheme: "arrows"

        //рекорди
        property int highScoreEasy: 0
        property int highScoreNormal: 0
        property int highScoreHard: 0
    }


    //звуки та музика
    property int previousScoreForSound: 0

    AudioOutput {
        id: musicOutput
        volume: 0.65
    }

    MediaPlayer {
        id: musicPlayer

        source: "qrc:/sounds/music_loop.wav"
        audioOutput: musicOutput
        loops: MediaPlayer.Infinite
    }

    SoundEffect {
        id: eatSound
        source: "qrc:/sounds/eat.wav"
        volume: 1.0
    }

    SoundEffect {
        id: clickSound
        source: "qrc:/sounds/click1.wav"
        volume: 0.70
    }

    SoundEffect {
        id: pauseSound
        source: "qrc:/sounds/click1.wav"
        volume: 0.60
    }

    SoundEffect {
        id: gameOverSound
        source: "qrc:/sounds/game_over1.wav"
        volume: 1.0
    }

    function playEffect(effect) {
        if (!applicationSettings.soundEnabled)
            return

        effect.stop()
        effect.play()
    }

    function playClickSound() {
        window.playEffect(clickSound)
    }

    function playEatSound() {
        window.playEffect(eatSound)
    }

    function playGameOverSound() {
        if (!applicationSettings.soundEnabled)
            return

        gameOverSound.stop()
        gameOverSound.play()
    }

    function playPauseSound() {
        window.playEffect(pauseSound)
    }

    function updateMusicState() {
        if (applicationSettings.musicEnabled) {
            if (musicPlayer.playbackState !== MediaPlayer.PlayingState)
                musicPlayer.play()
        } else {
            musicPlayer.stop()
        }
    }

    Connections {
        target: applicationSettings

        function onMusicEnabledChanged() {
            window.updateMusicState()
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: false

        onTriggered: {
            window.updateMusicState()
        }
    }

    //перемикання фулскрін режиму
    function toggleFullscreen() {
        if (window.visibility === Window.FullScreen)
            window.showNormal()
        else
            window.showFullScreen()
    }

    function updateHighScore() {
        if (window.selectedDifficulty === "easy") {
            if (gameController.score > applicationSettings.highScoreEasy)
                applicationSettings.highScoreEasy = gameController.score
        } else if (window.selectedDifficulty === "hard") {
            if (gameController.score > applicationSettings.highScoreHard)
                applicationSettings.highScoreHard = gameController.score
        } else {
            if (gameController.score > applicationSettings.highScoreNormal)
                applicationSettings.highScoreNormal = gameController.score
        }
    }

    //фон вікна
    Rectangle {
        anchors.fill: parent
        color: "#151A14"
    }

    //внутр. обл. програми
    Item {
        id: contentArea

            x: window.sideBorderWidth
            y: window.titlebarHeight

            width: Math.max(
                       0,
                       window.width - window.sideBorderWidth * 2
                   )

            height: Math.max(
                        0,
                        window.height
                        - window.titlebarHeight
                        - window.bottomBorderHeight
                    )

            clip: true
            z: 1

        Rectangle {
            anchors.fill: parent
            color: "#1E2B22"
        }

        //головне меню
        MainMenu {
            id: mainMenu

            anchors.fill: parent
            visible: window.currentScreen === "menu"

            pixelScale: window.contentScale
            pixelFontFamily: window.pixelFontFamily
            selectedDifficulty: window.selectedDifficulty

            highScoreEasy: applicationSettings.highScoreEasy
            highScoreNormal: applicationSettings.highScoreNormal
            highScoreHard: applicationSettings.highScoreHard

            //обрана складність запам'ятовується
            onDifficultyChanged: function(difficulty) {
                window.selectedDifficulty = difficulty
            }

            //перехід до ігрового екрана
            onStartRequested: function(difficulty) {
                window.selectedDifficulty = difficulty
                window.previousScoreForSound = 0

                gameController.startGame(difficulty)
                window.currentScreen = "game"
            }

            //перехід до налашт.
            onSettingsRequested: {
                window.currentScreen = "settings"
            }
        }

        //екран налаштувань
        Item {
            id: settingsScreen

            anchors.fill: parent
            visible: window.currentScreen === "settings"

            Rectangle {
                id: settingsPanel

                anchors.centerIn: parent

                width: 190 * window.pixelScale
                height: 170 * window.pixelScale

                color: "#e4d9c1"
                border.color: "#2e1502"
                border.width: 2 * window.pixelScale

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4 * window.pixelScale

                    color: "transparent"
                    border.color: "#7B4A22"
                    border.width: window.pixelScale
                }

                Column {
                    id: settingsColumn

                    anchors.centerIn: parent

                    width: 150 * window.pixelScale
                    spacing: 7 * window.pixelScale

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 118 * window.pixelScale
                        height: 18 * window.pixelScale

                        color: "#2e1502"

                        Text {
                            anchors.centerIn: parent

                            text: "SETTINGS"
                            color: "#F5E6B8"

                            font.family: window.pixelFontFamily
                            font.pixelSize: 6 * window.pixelScale

                            renderType: Text.NativeRendering
                            antialiasing: false
                        }
                    }

                    Item {
                        width: 1
                        height: 3 * window.pixelScale
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 96 * window.pixelScale
                        height: 18 * window.pixelScale
                        spacing: 8 * window.pixelScale

                        Text {
                            width: 68 * window.pixelScale
                            height: parent.height

                            text: "MUSIC"
                            color: "#2e1502"

                            font.family: window.pixelFontFamily
                            font.pixelSize: 5 * window.pixelScale

                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight

                            renderType: Text.NativeRendering
                            antialiasing: false
                        }

                        GameButton {
                            width: 16 * window.pixelScale
                            height: 16 * window.pixelScale
                            anchors.verticalCenter: parent.verticalCenter

                            normalSource:
                                applicationSettings.musicEnabled
                                ? "qrc:/images/buttons/music_on_button_normal.png"
                                : "qrc:/images/buttons/music_off_button_normal.png"

                            hoverSource:
                                applicationSettings.musicEnabled
                                ? "qrc:/images/buttons/music_on_button_hover.png"
                                : "qrc:/images/buttons/music_off_button_hover.png"

                            pressedSource:
                                applicationSettings.musicEnabled
                                ? "qrc:/images/buttons/music_on_button_pressed.png"
                                : "qrc:/images/buttons/music_off_button_pressed.png"

                            onClicked: {
                                applicationSettings.musicEnabled =
                                    !applicationSettings.musicEnabled
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 96 * window.pixelScale
                        height: 18 * window.pixelScale
                        spacing: 8 * window.pixelScale

                        Text {
                            width: 68 * window.pixelScale
                            height: parent.height

                            text: "SOUND"
                            color: "#2e1502"

                            font.family: window.pixelFontFamily
                            font.pixelSize: 5 * window.pixelScale

                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight

                            renderType: Text.NativeRendering
                            antialiasing: false
                        }

                        GameButton {
                            width: 16 * window.pixelScale
                            height: 16 * window.pixelScale
                            anchors.verticalCenter: parent.verticalCenter

                            normalSource:
                                applicationSettings.soundEnabled
                                ? "qrc:/images/buttons/sound_on_button_normal.png"
                                : "qrc:/images/buttons/sound_off_button_normal.png"

                            hoverSource:
                                applicationSettings.soundEnabled
                                ? "qrc:/images/buttons/sound_on_button_hover.png"
                                : "qrc:/images/buttons/sound_off_button_hover.png"

                            pressedSource:
                                applicationSettings.soundEnabled
                                ? "qrc:/images/buttons/sound_on_button_pressed.png"
                                : "qrc:/images/buttons/sound_off_button_pressed.png"

                            onClicked: {
                                applicationSettings.soundEnabled =
                                    !applicationSettings.soundEnabled
                            }
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 120 * window.pixelScale
                        height: window.pixelScale

                        color: "#2e1502"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: "CONTROLS"
                        color: "#2e1502"

                        font.family: window.pixelFontFamily
                        font.pixelSize: 5 * window.pixelScale

                        renderType: Text.NativeRendering
                        antialiasing: false
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 148 * window.pixelScale
                        height: 20 * window.pixelScale
                        spacing: 8 * window.pixelScale

                        Rectangle {
                            id: arrowsButton

                            width: 70 * window.pixelScale
                            height: 20 * window.pixelScale

                            color: {
                                if (arrowsMouse.pressed)
                                    return "#5F3B22"

                                if (applicationSettings.controlScheme === "arrows")
                                    return "#B8793A"

                                if (arrowsMouse.containsMouse)
                                    return "#8B5A2B"

                                return "#4E321D"
                            }

                            border.color:
                                applicationSettings.controlScheme === "arrows"
                                ? "#F2B84B"
                                : "#2e1502"

                            border.width: window.pixelScale

                            Text {
                                anchors.centerIn: parent

                                text: "ARROWS"
                                color: "#FFE6A3"

                                font.family: window.pixelFontFamily
                                font.pixelSize: 5 * window.pixelScale

                                renderType: Text.NativeRendering
                                antialiasing: false
                            }

                            MouseArea {
                                id: arrowsMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    applicationSettings.controlScheme = "arrows"
                                }
                            }
                        }

                        Rectangle {
                            id: wasdButton

                            width: 70 * window.pixelScale
                            height: 20 * window.pixelScale

                            color: {
                                if (wasdMouse.pressed)
                                    return "#5F3B22"

                                if (applicationSettings.controlScheme === "wasd")
                                    return "#B8793A"

                                if (wasdMouse.containsMouse)
                                    return "#8B5A2B"

                                return "#4E321D"
                            }

                            border.color:
                                applicationSettings.controlScheme === "wasd"
                                ? "#F2B84B"
                                : "#2e1502"

                            border.width: window.pixelScale

                            Text {
                                anchors.centerIn: parent

                                text: "WASD"
                                color: "#FFE6A3"

                                font.family: window.pixelFontFamily
                                font.pixelSize: 5 * window.pixelScale

                                renderType: Text.NativeRendering
                                antialiasing: false
                            }

                            MouseArea {
                                id: wasdMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    applicationSettings.controlScheme = "wasd"
                                }
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 150 * window.pixelScale

                        text:
                            applicationSettings.controlScheme === "arrows"
                            ? "USE ARROW KEYS TO MOVE"
                            : "USE W A S D TO MOVE"

                        color: "#267C17"

                        font.family: window.pixelFontFamily
                        font.pixelSize: 4 * window.pixelScale

                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap

                        renderType: Text.NativeRendering
                        antialiasing: false
                    }

                    Item {
                        width: 1
                        height: 2 * window.pixelScale
                    }

                    GameButton {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 64 * window.pixelScale
                        height: 16 * window.pixelScale

                        normalSource: "qrc:/images/buttons/back_button_normal.png"
                        hoverSource: "qrc:/images/buttons/back_button_hover.png"
                        pressedSource: "qrc:/images/buttons/back_button_pressed.png"

                        onClicked: {
                            window.currentScreen = "menu"
                        }
                    }
                }
            }
        }

        //ігровий екран
        GameScene {
            id: gameScene

            anchors.fill: parent
            visible: window.currentScreen === "game"

            pixelScale: window.contentScale
            pixelFontFamily: window.pixelFontFamily
            gameController: gameController
            controlScheme: applicationSettings.controlScheme

            onMenuRequested: {
                window.currentScreen = "menu"
            }

            onRestartRequested: {
                console.log("Перезапуск гри")
            }
        }
    }

    //верхня панель і рамка вікна
    Image {
        id: titlebarTile

        x: window.sideBorderWidth
        y: 0

        width: Math.max(
                   0,
                   window.width - window.sideBorderWidth * 2
               )

        height: window.titlebarHeight

        source: "qrc:/images/ui/titlebar.png"

        sourceSize.width: 32 * window.pixelScale
        sourceSize.height: 32 * window.pixelScale

        fillMode: Image.TileHorizontally

        smooth: false
        mipmap: false

        z: 10
    }

    Image {
        x: 0
        y: 0

        width: window.sideBorderWidth
        height: window.titlebarHeight

        source: "qrc:/images/ui/corner_top_left.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 32 * window.pixelScale

        smooth: false
        mipmap: false

        z: 11
    }

    Image {
        x: window.width - window.sideBorderWidth
        y: 0

        width: window.sideBorderWidth
        height: window.titlebarHeight

        source: "qrc:/images/ui/corner_top_right.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 32 * window.pixelScale

        smooth: false
        mipmap: false

        z: 11
    }

    Image {
        x: 0
        y: window.titlebarHeight

        width: window.sideBorderWidth

        height: Math.max(
                    0,
                    window.height
                    - window.titlebarHeight
                    - window.bottomBorderHeight
                )

        source: "qrc:/images/ui/border_vertical.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 16 * window.pixelScale

        fillMode: Image.TileVertically

        smooth: false
        mipmap: false

        z: 10
    }

    Image {
        x: window.width - window.sideBorderWidth
        y: window.titlebarHeight

        width: window.sideBorderWidth

        height: Math.max(
                    0,
                    window.height
                    - window.titlebarHeight
                    - window.bottomBorderHeight
                )

        source: "qrc:/images/ui/border_vertical.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 16 * window.pixelScale

        fillMode: Image.TileVertically

        smooth: false
        mipmap: false

        z: 10
    }

    Image {
        x: window.sideBorderWidth
        y: window.height - window.bottomBorderHeight

        width: Math.max(
                   0,
                   window.width - window.sideBorderWidth * 2
               )

        height: window.bottomBorderHeight

        source: "qrc:/images/ui/border_horizontal.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 16 * window.pixelScale

        fillMode: Image.TileHorizontally

        smooth: false
        mipmap: false

        z: 10
    }

    Image {
        x: 0
        y: window.height - window.bottomBorderHeight

        width: window.sideBorderWidth
        height: window.bottomBorderHeight

        source: "qrc:/images/ui/corner_bottom_left.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 16 * window.pixelScale

        smooth: false
        mipmap: false

        z: 11
    }

    Image {
        x: window.width - window.sideBorderWidth
        y: window.height - window.bottomBorderHeight

        width: window.sideBorderWidth
        height: window.bottomBorderHeight

        source: "qrc:/images/ui/corner_bottom_right.png"

        sourceSize.width: 16 * window.pixelScale
        sourceSize.height: 16 * window.pixelScale

        smooth: false
        mipmap: false

        z: 11
    }

    //іконка
    Image {
        id: titleIcon

        x: window.sideBorderWidth
           + 4 * window.pixelScale

        y: Math.round(
               (window.titlebarHeight - height) / 2
           )

        width: 32 * window.pixelScale
        height: 32 * window.pixelScale

        source: "qrc:/images/icons/icon.ico"

        sourceSize.width: 32 * window.pixelScale
        sourceSize.height: 32 * window.pixelScale

        fillMode: Image.PreserveAspectFit

        smooth: false
        mipmap: false

        z: 20
    }

    //назва програми
    Text {
        id: titleText

        anchors.left: titleIcon.right
        anchors.leftMargin: 4 * window.pixelScale
        anchors.verticalCenter: titleIcon.verticalCenter

        text: "SNAKE"
        color: "#170c07"

        font.family: window.pixelFontFamily
        font.pixelSize: 10 * window.pixelScale

        renderType: Text.NativeRendering
        antialiasing: false

        z: 20
    }

    //кнопки керування вікном
    Row {
        id: windowButtons

        anchors.right: parent.right
        anchors.rightMargin:
            window.sideBorderWidth
            + 4 * window.pixelScale

        y: Math.round(
               (window.titlebarHeight - height) / 2
           )

        height: 16 * window.pixelScale
        spacing: 2 * window.pixelScale

        z: 21

        GameButton {
            width: 16 * window.pixelScale
            height: 16 * window.pixelScale

            normalSource:
                "qrc:/images/buttons/minimize_button_normal.png"

            hoverSource:
                "qrc:/images/buttons/minimize_button_hover.png"

            pressedSource:
                "qrc:/images/buttons/minimize_button_pressed.png"

            onClicked: {
                window.showMinimized()
            }
        }

        GameButton {
            width: 16 * window.pixelScale
            height: 16 * window.pixelScale

            selected:
                window.visibility === Window.FullScreen

            normalSource:
                "qrc:/images/buttons/maximize_button_normal.png"

            hoverSource:
                "qrc:/images/buttons/maximize_button_hover.png"

            pressedSource:
                "qrc:/images/buttons/maximize_button_pressed.png"

            onClicked: {
                window.toggleFullscreen()
            }
        }

        GameButton {
            width: 16 * window.pixelScale
            height: 16 * window.pixelScale

            normalSource:
                "qrc:/images/buttons/close_button_normal.png"

            hoverSource:
                "qrc:/images/buttons/close_button_hover.png"

            pressedSource:
                "qrc:/images/buttons/close_button_pressed.png"

            onClicked: {
                window.close()
            }
        }
    }

    //область перетягування верхньої панелі
    MouseArea {
        id: titlebarDragArea

        x: window.sideBorderWidth
        y: 0

        width: Math.max(
                   0,
                   window.width
                   - window.sideBorderWidth * 2
                   - windowButtons.width
                   - 12 * window.pixelScale
               )

        height: window.titlebarHeight

        acceptedButtons: Qt.LeftButton

        enabled:
            window.visibility !== Window.FullScreen

        cursorShape: Qt.SizeAllCursor

        onPressed: function(mouse) {
            window.startSystemMove()
        }

        z: 15
    }
}