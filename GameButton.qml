import QtQuick
import QtQuick.Window

Item {
    id: root

    //шляхи до 3 станів кнопки
    property string normalSource: ""
    property string hoverSource: ""
    property string pressedSource: ""

    //кнопка може бути постійно в стані пресд
    property bool selected: false

    //можна вимикати кнопку
    property bool enabled: true

    //чи треба програвати звук кліку
    property bool clickSoundEnabled: true

    //сигнал натискання
    signal clicked()

    //поточ. стан мишки
    property bool hovered: false
    property bool mousePressed: false

    implicitWidth: buttonImage.implicitWidth
    implicitHeight: buttonImage.implicitHeight

    Image {
        id: buttonImage

        anchors.fill: parent

        //картинка залежно від стану кнопки
        source: {
            if (!root.enabled)
                return root.normalSource

            if (root.selected)
                return root.pressedSource

            if (root.mousePressed)
                return root.pressedSource

            if (root.hovered)
                return root.hoverSource

            return root.normalSource
        }

        //щоб не розмивалось
        smooth: false
        mipmap: false
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.hovered = true
        }

        onExited: {
            root.hovered = false
            root.mousePressed = false
        }

        onPressed: {
            root.mousePressed = true

            if (root.clickSoundEnabled
                    && Window.window
                    && Window.window.playClickSound) {
                Window.window.playClickSound()
            }
        }

        onReleased: {
            root.mousePressed = false
        }

        onClicked: {
            root.clicked()
        }
    }
}