import QtQuick

Item {
    id: root

    property int pixelScale: 3
    property string selectedDifficulty: "normal"
    property string pixelFontFamily: ""

    property int highScoreEasy: 0
    property int highScoreNormal: 0
    property int highScoreHard: 0

    signal startRequested(string difficulty)
    signal settingsRequested()
    signal difficultyChanged(string difficulty)

    function selectDifficulty(difficulty) {
        selectedDifficulty = difficulty
        difficultyChanged(difficulty)
    }

    function difficultyText() {
        if (easyButton.hovered)
            return "EASY\nFIELD: 19 x 13\nSLOW SPEED\nNO OBSTACLES\nWALLS: PORTALS"

        if (normalButton.hovered)
            return "NORMAL\nFIELD: 19 x 13\nMEDIUM SPEED\n3 OBSTACLES\nWALLS: DANGEROUS"

        if (hardButton.hovered)
            return "HARD\nFIELD: 17 x 12\nHIGH SPEED\n5 OBSTACLES\nWALLS: DANGEROUS"

        return ""
    }

    //відстеження позиції курсору для підказки
    HoverHandler {
        id: hoverTracker
        acceptedDevices: PointerDevice.Mouse
    }

    //фон меню з тайлів трави
    Repeater {
        model: Math.ceil(root.width / (16 * root.pixelScale))
               * Math.ceil(root.height / (16 * root.pixelScale))

        Image {
            width: 16 * root.pixelScale
            height: 16 * root.pixelScale

            x: (index % Math.ceil(root.width / (16 * root.pixelScale)))
               * width

            y: Math.floor(index / Math.ceil(root.width / (16 * root.pixelScale)))
               * height

            source: {
                var xCell = index % Math.ceil(root.width / (16 * root.pixelScale))
                var yCell = Math.floor(index / Math.ceil(root.width / (16 * root.pixelScale)))
                var tileNumber = ((xCell * 7 + yCell * 11 + xCell * yCell) % 3) + 1

                return "qrc:/images/tiles/grass_tile_" + tileNumber + ".png"
            }

            opacity: 0.45

            smooth: false
            mipmap: false
        }
    }

    //затемнення поверх трави
    Rectangle {
        anchors.fill: parent
        color: "#102017"
        opacity: 0.1
    }

    //логотип
    Image {
        id: logoImage

        anchors.top: parent.top
        anchors.topMargin: 12 * root.pixelScale
        anchors.horizontalCenter: parent.horizontalCenter

        width: 256 * root.pixelScale
        height: 64 * root.pixelScale

        source: "qrc:/images/logo/logo.png"

        smooth: false
        mipmap: false
        fillMode: Image.PreserveAspectFit
    }

    //загальна область меню
    Item {
        id: menuLayout

        anchors.top: logoImage.bottom
        anchors.topMargin: 14 * root.pixelScale
        anchors.horizontalCenter: parent.horizontalCenter

        width: 268 * root.pixelScale
        height: 128 * root.pixelScale

        //ліва частина
        Column {
            id: menuColumn

            anchors.left: parent.left
            anchors.leftMargin: 10 * root.pixelScale
            anchors.top: parent.top

            width: 124 * root.pixelScale
            spacing: 7 * root.pixelScale

            Rectangle {
                id: startPanel

                anchors.horizontalCenter: parent.horizontalCenter

                width: 96 * root.pixelScale
                height: 28 * root.pixelScale

                color: "#00000000"
                border.color: "#8cff00"
                border.width: 2 * root.pixelScale

                GameButton {
                    anchors.centerIn: parent

                    width: 64 * root.pixelScale
                    height: 16 * root.pixelScale

                    normalSource: "qrc:/images/buttons/start_button_normal.png"
                    hoverSource: "qrc:/images/buttons/start_button_hover.png"
                    pressedSource: "qrc:/images/buttons/start_button_pressed.png"

                    onClicked: {
                        root.startRequested(root.selectedDifficulty)
                    }
                }
            }

            Rectangle {
                id: difficultyPanel

                anchors.horizontalCenter: parent.horizontalCenter

                width: 124 * root.pixelScale
                height: 78 * root.pixelScale

                color: "#00000000"
                border.color: "#2e1502"
                border.width: 2 * root.pixelScale

                Column {
                    anchors.centerIn: parent
                    spacing: 3 * root.pixelScale

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 104 * root.pixelScale
                        height: 16 * root.pixelScale

                        color: "#2e1502"

                        Text {
                            anchors.centerIn: parent

                            text: "DIFFICULTY"
                            color: "#F5E6B8"

                            font.family: root.pixelFontFamily.length > 0
                                         ? root.pixelFontFamily
                                         : "monospace"

                            font.pixelSize: 5 * root.pixelScale

                            renderType: Text.NativeRendering
                            antialiasing: false
                        }
                    }

                    Item {
                        width: 1
                        height: 1 * root.pixelScale
                    }

                    Column {
                        id: difficultyButtons

                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2 * root.pixelScale

                        GameButton {
                            id: easyButton

                            width: 64 * root.pixelScale
                            height: 16 * root.pixelScale

                            selected: root.selectedDifficulty === "easy"

                            normalSource: "qrc:/images/buttons/easy_mode_button_normal.png"
                            hoverSource: "qrc:/images/buttons/easy_mode_button_hover.png"
                            pressedSource: "qrc:/images/buttons/easy_mode_button_pressed.png"

                            onClicked: {
                                root.selectDifficulty("easy")
                            }
                        }

                        GameButton {
                            id: normalButton

                            width: 64 * root.pixelScale
                            height: 16 * root.pixelScale

                            selected: root.selectedDifficulty === "normal"

                            normalSource: "qrc:/images/buttons/normal_mode_button_normal.png"
                            hoverSource: "qrc:/images/buttons/normal_mode_button_hover.png"
                            pressedSource: "qrc:/images/buttons/normal_mode_button_pressed.png"

                            onClicked: {
                                root.selectDifficulty("normal")
                            }
                        }

                        GameButton {
                            id: hardButton

                            width: 64 * root.pixelScale
                            height: 16 * root.pixelScale

                            selected: root.selectedDifficulty === "hard"

                            normalSource: "qrc:/images/buttons/hard_mode_button_normal.png"
                            hoverSource: "qrc:/images/buttons/hard_mode_button_hover.png"
                            pressedSource: "qrc:/images/buttons/hard_mode_button_pressed.png"

                            onClicked: {
                                root.selectDifficulty("hard")
                            }
                        }
                    }
                }
            }

            GameButton {
                width: 96 * root.pixelScale
                height: 16 * root.pixelScale
                anchors.horizontalCenter: parent.horizontalCenter

                normalSource: "qrc:/images/buttons/settings_button_normal.png"
                hoverSource: "qrc:/images/buttons/settings_button_hover.png"
                pressedSource: "qrc:/images/buttons/settings_button_pressed.png"

                onClicked: {
                    root.settingsRequested()
                }
            }
        }

        //права частина рекорди
        Rectangle {
            id: highScorePanel

            anchors.right: parent.right
            anchors.rightMargin: 8 * root.pixelScale
            anchors.top: parent.top
            anchors.topMargin: 36 * root.pixelScale

            width: 104 * root.pixelScale
            height: 86 * root.pixelScale

            color: "#e4d9c1"
            border.color: "#2e1502"
            border.width: 2 * root.pixelScale

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4 * root.pixelScale

                color: "transparent"
                border.color: "#7B4A22"
                border.width: root.pixelScale
            }

            Column {
                anchors.fill: parent
                anchors.margins: 8 * root.pixelScale

                spacing: 4 * root.pixelScale

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "BEST"
                    color: "#2e1502"

                    font.family: root.pixelFontFamily.length > 0
                                 ? root.pixelFontFamily
                                 : "monospace"

                    font.pixelSize: 7 * root.pixelScale

                    renderType: Text.NativeRendering
                    antialiasing: false
                }

                Item {
                    width: parent.width
                    height: 16 * root.pixelScale

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        text: "EASY"
                        color: "#37F02A"

                        font.family: root.pixelFontFamily.length > 0
                                     ? root.pixelFontFamily
                                     : "monospace"

                        font.pixelSize: 5 * root.pixelScale

                        style: Text.Outline
                        styleColor: "#2e1502"

                        renderType: Text.NativeRendering
                        antialiasing: false
                    }

                    DigitDisplay {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        value: root.highScoreEasy
                        pixelScale: root.pixelScale
                    }
                }

                Item {
                    width: parent.width
                    height: 16 * root.pixelScale

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        text: "NORM"
                        color: "#FF9A1F"

                        font.family: root.pixelFontFamily.length > 0
                                     ? root.pixelFontFamily
                                     : "monospace"

                        font.pixelSize: 5 * root.pixelScale

                        style: Text.Outline
                        styleColor: "#2e1502"

                        renderType: Text.NativeRendering
                        antialiasing: false
                    }

                    DigitDisplay {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        value: root.highScoreNormal
                        pixelScale: root.pixelScale
                    }
                }

                Item {
                    width: parent.width
                    height: 16 * root.pixelScale

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        text: "HARD"
                        color: "#F22535"

                        font.family: root.pixelFontFamily.length > 0
                                     ? root.pixelFontFamily
                                     : "monospace"

                        font.pixelSize: 5 * root.pixelScale

                        style: Text.Outline
                        styleColor: "#2e1502"

                        renderType: Text.NativeRendering
                        antialiasing: false
                    }

                    DigitDisplay {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        value: root.highScoreHard
                        pixelScale: root.pixelScale
                    }
                }
            }
        }
    }

    //випадаюча підказка біля курсору
    Rectangle {
        id: difficultyHint

        visible: easyButton.hovered
                 || normalButton.hovered
                 || hardButton.hovered

        width: 116 * root.pixelScale
        height: 54 * root.pixelScale

        x: Math.min(
               hoverTracker.point.position.x + 8 * root.pixelScale,
               root.width - width - 4 * root.pixelScale
           )

        y: Math.min(
               hoverTracker.point.position.y + 8 * root.pixelScale,
               root.height - height - 4 * root.pixelScale
           )

        color: "#263D2A"
        border.color: "#B8793A"
        border.width: root.pixelScale

        z: 100

        Text {
            anchors.fill: parent
            anchors.margins: 5 * root.pixelScale

            text: root.difficultyText()
            color: "#F5E6B8"

            font.family: root.pixelFontFamily.length > 0
                         ? root.pixelFontFamily
                         : "monospace"

            font.pixelSize: 5 * root.pixelScale

            lineHeightMode: Text.FixedHeight
            lineHeight: 8 * root.pixelScale

            style: Text.Outline
            styleColor: "#2B1F18"

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            textFormat: Text.PlainText
            wrapMode: Text.NoWrap

            renderType: Text.NativeRendering
            antialiasing: false
        }
    }
}