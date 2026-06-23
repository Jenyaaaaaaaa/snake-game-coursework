import QtQuick

Item {
    id: root

    property int pixelScale: 2
    property string pixelFontFamily: ""
    property var gameController: null

    //керування: стрілки або васд
    property string controlScheme: "arrows"

    property int score: gameController ? gameController.score : 0
    property int columns: gameController ? gameController.columns : 19
    property int rows: gameController ? gameController.rows : 13
    property int cellSize: 16 * pixelScale
    property bool paused: gameController ? gameController.paused : false
    property bool gameOver: gameController ? gameController.gameOver : false
    //кадр анімації тіла
    property int bodyAnimationFrame: 0

    //кадри анімації рота
    property int mouthFrameIndex: -1
    property var mouthFrames: [
        "head_right_eat_1.png",
        "head_right_eat_2.png",
        "head_right_eat_3.png",
        "head_right_eat_4.png",
        "head_right_eat_3.png",
        "head_right_eat_2.png",
        "head_right_eat_1.png"
    ]

    signal menuRequested()
    signal restartRequested()

    readonly property int fieldWidth: columns * cellSize
    readonly property int fieldHeight: rows * cellSize

    property int appleX: 9
    property int appleY: 7

    property var testSnake: [
        { "x": 5, "y": 8, "sprite": "head_right.png" },
        { "x": 4, "y": 8, "sprite": "body_horizontal.png" },
        { "x": 3, "y": 8, "sprite": "tail_left.png" }
    ]

    function headIsNearApple() {
        if (!root.gameController)
            return false

        var snake = root.gameController.snake

        if (!snake || snake.length === 0)
            return false

        var head = snake[0]
        var apple = root.gameController.apple

        var dx = Math.abs(head.x - apple.x)
        var dy = Math.abs(head.y - apple.y)

        return dx + dy <= 3
    }

    function headRotation(sprite) {
        if (sprite === "head_down.png")
            return 90

        if (sprite === "head_left.png")
            return 180

        if (sprite === "head_up.png")
            return -90

        return 0
    }

    function isTeleportMove(previousX, previousY, currentX, currentY) {
        return Math.abs(currentX - previousX) > 1
                || Math.abs(currentY - previousY) > 1
    }

    function movingBodySprite(originalSprite, previousX, previousY, currentX, currentY, segmentIndex) {
        if (segmentIndex === 0)
            return originalSprite

        if (originalSprite.indexOf("tail_") === 0)
            return originalSprite

        if (!root.gameController || root.gameController.moveProgress > 0.85)
            return originalSprite

        var dx = currentX - previousX
        var dy = currentY - previousY

        if (dx !== 0)
            return "body_horizontal.png"

        if (dy !== 0)
            return "body_vertical.png"

        return originalSprite
    }

    focus: true

    Keys.onPressed: function(event) {
        if (!root.gameController)
            return

        //пауза на ескейп
        if (event.key === Qt.Key_Escape) {
            if (!root.gameOver) {
                root.gameController.pauseGame()
                forceActiveFocus()
            }

            event.accepted = true
            return
        }

        if (root.paused || root.gameOver)
            return

        if (root.controlScheme === "arrows") {
            if (event.key === Qt.Key_Up) {
                root.gameController.moveUp()
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                root.gameController.moveDown()
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                root.gameController.moveLeft()
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                root.gameController.moveRight()
                event.accepted = true
            }
        } else {
            if (event.key === Qt.Key_W) {
                root.gameController.moveUp()
                event.accepted = true
            } else if (event.key === Qt.Key_S) {
                root.gameController.moveDown()
                event.accepted = true
            } else if (event.key === Qt.Key_A) {
                root.gameController.moveLeft()
                event.accepted = true
            } else if (event.key === Qt.Key_D) {
                root.gameController.moveRight()
                event.accepted = true
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus()
        }
    }

    Component.onCompleted: {
        forceActiveFocus()
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            root.forceActiveFocus()
        }
    }

    //для легкої анімації тіла
    Timer {
        interval: 160
        running: root.gameController && !root.paused && !root.gameOver
        repeat: true

        onTriggered: {
            root.bodyAnimationFrame =
                (root.bodyAnimationFrame + 1) % 4
        }
    }

    //для анімації рота
    Timer {
        id: mouthAnimationTimer

        interval: 70
        running: false
        repeat: true

        onTriggered: {
            root.mouthFrameIndex++

            if (root.mouthFrameIndex >= root.mouthFrames.length) {
                root.mouthFrameIndex = -1
                stop()
            }
        }
    }

    //чи голова біля яблука
    Timer {
        interval: 50
        running: root.gameController && !root.paused && !root.gameOver
        repeat: true

        onTriggered: {
            if (root.headIsNearApple()
                    && !mouthAnimationTimer.running) {
                root.mouthFrameIndex = 0
                mouthAnimationTimer.start()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#02c97a"
    }

    //верхня панель
    Item {
        id: hud

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 24 * root.pixelScale

        Row {
            id: scoreRow

            anchors.left: parent.left
            anchors.leftMargin: 8 * root.pixelScale
            anchors.top: parent.top
            anchors.topMargin: 8 * root.pixelScale

            spacing: 2 * root.pixelScale

            Text {
                text: "SCORE"
                color: "#F5E6B8"

                font.family: root.pixelFontFamily.length > 0
                             ? root.pixelFontFamily
                             : "monospace"

                font.pixelSize: 10 * root.pixelScale

                style: Text.Outline
                styleColor: "#170c07"

                renderType: Text.NativeRendering
                antialiasing: false
            }

            Repeater {
                model: root.score.toString().split("")

                Image {
                    width: 8 * root.pixelScale
                    height: 16 * root.pixelScale

                    source: "qrc:/images/digits/digit_" + modelData + ".png"

                    smooth: false
                    mipmap: false
                }
            }
        }

        GameButton {
            anchors.right: parent.right
            anchors.rightMargin: 8 * root.pixelScale
            anchors.top: parent.top
            anchors.topMargin: 6 * root.pixelScale

            width: 16 * root.pixelScale
            height: 16 * root.pixelScale

            normalSource: "qrc:/images/buttons/pause_button_normal.png"
            hoverSource: "qrc:/images/buttons/pause_button_hover.png"
            pressedSource: "qrc:/images/buttons/pause_button_pressed.png"

            onClicked: {
                if (root.gameController)
                    root.gameController.pauseGame()

                forceActiveFocus()
            }
        }
    }

    //рамка навколо поля
    Rectangle {
        id: fieldFrame

        width: root.fieldWidth + 2 * root.pixelScale
        height: root.fieldHeight + 2 * root.pixelScale

        anchors.top: hud.bottom
        anchors.topMargin: 2 * root.pixelScale
        anchors.horizontalCenter: parent.horizontalCenter

        color: "transparent"
        border.color: "#170c07"
        border.width: root.pixelScale

        Item {
            id: gameField

            anchors.centerIn: parent

            width: root.fieldWidth
            height: root.fieldHeight

            clip: true

            //трава
            Repeater {
                model: root.columns * root.rows

                Image {
                    width: root.cellSize
                    height: root.cellSize

                    x: (index % root.columns) * root.cellSize
                    y: Math.floor(index / root.columns) * root.cellSize

                    source: {
                        var xCell = index % root.columns
                        var yCell = Math.floor(index / root.columns)
                        var tileNumber = ((xCell * 7 + yCell * 11 + xCell * yCell) % 3) + 1
                        return "qrc:/images/tiles/grass_tile_" + tileNumber + ".png"
                    }

                    smooth: false
                    mipmap: false
                }
            }

            //перешкоди
            Repeater {
                model: root.gameController ? root.gameController.obstacles : []

                Image {
                    width: root.cellSize
                    height: root.cellSize

                    x: modelData.x * root.cellSize
                    y: modelData.y * root.cellSize

                    source: "qrc:/images/obstacles/" + modelData.sprite

                    smooth: false
                    mipmap: false
                }
            }

            //яблуко
            Image {
                width: root.cellSize
                height: root.cellSize

                x: (root.gameController ? root.gameController.apple.x : root.appleX) * root.cellSize
                y: (root.gameController ? root.gameController.apple.y : root.appleY) * root.cellSize

                source: "qrc:/images/food/apple.png"

                smooth: false
                mipmap: false
            }

            //змійка
            Repeater {
                model: root.gameController ? root.gameController.snake : root.testSnake

                Image {
                    width: root.cellSize
                    height: root.cellSize

                    //поточна позиція сегмента
                    property real currentX: modelData.x
                    property real currentY: modelData.y

                    //попередня
                    property var previousSegment: {
                        if (!root.gameController || !root.gameController.previousSnake)
                            return modelData

                        var previousSnake = root.gameController.previousSnake

                        //голова рухається зі своєї старої позиції
                        if (index === 0) {
                            if (previousSnake.length > 0)
                                return previousSnake[0]

                            return modelData
                        }

                        //тіло бере попередню позицію сегмента, який був перед ним
                        if (index - 1 < previousSnake.length)
                            return previousSnake[index - 1]

                        return modelData
                    }

                    property real previousX: previousSegment.x
                    property real previousY: previousSegment.y

                    //прогрес руху
                    property real progress:
                        root.gameController ? root.gameController.moveProgress : 1.0

                    property bool teleportStep: {
                        if (!root.gameController || !root.gameController.previousSnake)
                            return false

                        var oldSnake = root.gameController.previousSnake
                        var newSnake = root.gameController.snake

                        if (!oldSnake || !newSnake || oldSnake.length === 0 || newSnake.length === 0)
                            return false

                        return root.isTeleportMove(
                            oldSnake[0].x,
                            oldSnake[0].y,
                            newSnake[0].x,
                            newSnake[0].y
                        )
                    }

                    x: {
                        //якщо голова перейшла через край поля кадр малюється без плавності
                        if (teleportStep)
                            return currentX * root.cellSize

                        return (previousX + (currentX - previousX) * progress)
                               * root.cellSize
                    }

                    y: {
                        if (teleportStep)
                            return currentY * root.cellSize

                        return (previousY + (currentY - previousY) * progress)
                               * root.cellSize
                    }

                    z: 100 - index



                    rotation: {
                        if (index !== 0)
                            return 0

                        if (root.mouthFrameIndex >= 0)
                            return root.headRotation(modelData.sprite)

                        return 0
                    }

                    source: {
                        var sprite = modelData.sprite

                        sprite = root.movingBodySprite(
                            sprite,
                            previousX,
                            previousY,
                            currentX,
                            currentY,
                            index
                        )

                        //анімація рота тільки для голови
                        if (index === 0
                                && root.mouthFrameIndex >= 0
                                && root.mouthFrameIndex < root.mouthFrames.length) {
                            sprite = root.mouthFrames[root.mouthFrameIndex]
                        }

                        //анімація горизонт. тіла
                        if (sprite === "body_horizontal.png") {
                            if (index === 1) {
                                sprite = "body_horizontal.png"
                            } else if (root.bodyAnimationFrame === 0) {
                                sprite = "body_horizontal1.png"
                            } else if (root.bodyAnimationFrame === 1) {
                                sprite = "body_horizontal.png"
                            } else if (root.bodyAnimationFrame === 2) {
                                sprite = "body_horizontal2.png"
                            } else {
                                sprite = "body_horizontal.png"
                            }
                        }

                        //анімація вертикал. тіла
                        if (sprite === "body_vertical.png") {
                            if (index === 1) {
                                sprite = "body_vertical.png"
                            } else if (root.bodyAnimationFrame === 0) {
                                sprite = "body_vertical1.png"
                            } else if (root.bodyAnimationFrame === 1) {
                                sprite = "body_vertical.png"
                            } else if (root.bodyAnimationFrame === 2) {
                                sprite = "body_vertical2.png"
                            } else {
                                sprite = "body_vertical.png"
                            }
                        }

                        return "qrc:/images/snake/" + sprite
                    }

                    smooth: false
                    mipmap: false
                }
            }
        }
    }

    //меню паузи
    Rectangle {
        id: pauseOverlay

        anchors.fill: parent
        visible: root.paused && !root.gameOver

        color: "#00000088"
        z: 50

        Rectangle {
            id: pausePanel

            anchors.centerIn: parent

            width: 92 * root.pixelScale
            height: 48 * root.pixelScale

            color: "#e4d9c1"
            border.color: "#2e1502"
            border.width: 2 * root.pixelScale

            Column {
                anchors.centerIn: parent
                spacing: 6 * root.pixelScale

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "PAUSED"
                    color: "#2e1502"

                    font.family: root.pixelFontFamily.length > 0
                                 ? root.pixelFontFamily
                                 : "monospace"

                    font.pixelSize: 7 * root.pixelScale

                    style: Text.Outline
                    styleColor: "#F5E6B8"

                    renderType: Text.NativeRendering
                    antialiasing: false
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6 * root.pixelScale

                    GameButton {
                        width: 16 * root.pixelScale
                        height: 16 * root.pixelScale

                        normalSource: "qrc:/images/buttons/resume_button_normal.png"
                        hoverSource: "qrc:/images/buttons/resume_button_hover.png"
                        pressedSource: "qrc:/images/buttons/resume_button_pressed.png"

                        onClicked: {
                            if (root.gameController)
                                root.gameController.resumeGame()

                            forceActiveFocus()
                        }
                    }

                    GameButton {
                        width: 16 * root.pixelScale
                        height: 16 * root.pixelScale

                        normalSource: "qrc:/images/buttons/restart_button_normal.png"
                        hoverSource: "qrc:/images/buttons/restart_button_hover.png"
                        pressedSource: "qrc:/images/buttons/restart_button_pressed.png"

                        onClicked: {
                            if (root.gameController)
                                root.gameController.restartGame()

                            root.restartRequested()
                            forceActiveFocus()
                        }
                    }

                    GameButton {
                        width: 16 * root.pixelScale
                        height: 16 * root.pixelScale

                        normalSource: "qrc:/images/buttons/menu_button_normal.png"
                        hoverSource: "qrc:/images/buttons/menu_button_hover.png"
                        pressedSource: "qrc:/images/buttons/menu_button_pressed.png"

                        onClicked: {
                            if (root.gameController)
                                root.gameController.stopGame()

                            root.menuRequested()
                        }
                    }
                }
            }
        }
    }

    //екран геймовер
    Rectangle {
        id: gameOverOverlay

        anchors.fill: parent
        visible: root.gameOver

        color: "#00000088"
        z: 60

        Rectangle {
            id: gameOverPanel

            anchors.centerIn: parent

            width: 112 * root.pixelScale
            height: 50 * root.pixelScale

            color: "#e4d9c1"
            border.color: "#2e1502"
            border.width: 2 * root.pixelScale

            Column {
                anchors.centerIn: parent
                spacing: 6 * root.pixelScale

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "GAME OVER"
                    color: "#2e1502"

                    font.family: root.pixelFontFamily.length > 0
                                 ? root.pixelFontFamily
                                 : "monospace"

                    font.pixelSize: 7 * root.pixelScale

                    style: Text.Outline
                    styleColor: "#F5E6B8"

                    renderType: Text.NativeRendering
                    antialiasing: false
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6 * root.pixelScale

                    GameButton {
                        width: 16 * root.pixelScale
                        height: 16 * root.pixelScale

                        normalSource: "qrc:/images/buttons/restart_button_normal.png"
                        hoverSource: "qrc:/images/buttons/restart_button_hover.png"
                        pressedSource: "qrc:/images/buttons/restart_button_pressed.png"

                        onClicked: {
                            if (root.gameController)
                                root.gameController.restartGame()

                            root.restartRequested()
                            forceActiveFocus()
                        }
                    }

                    GameButton {
                        width: 16 * root.pixelScale
                        height: 16 * root.pixelScale

                        normalSource: "qrc:/images/buttons/menu_button_normal.png"
                        hoverSource: "qrc:/images/buttons/menu_button_hover.png"
                        pressedSource: "qrc:/images/buttons/menu_button_pressed.png"

                        onClicked: {
                            if (root.gameController)
                                root.gameController.stopGame()

                            root.menuRequested()
                        }
                    }
                }
            }
        }
    }
}