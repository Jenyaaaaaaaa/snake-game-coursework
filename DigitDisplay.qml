import QtQuick

Row {
    id: root

    property int value: 0
    property int pixelScale: 2

    spacing: 1 * root.pixelScale

    Repeater {
        model: root.value.toString().split("")

        Image {
            width: 8 * root.pixelScale
            height: 16 * root.pixelScale

            source: "qrc:/images/digits/digit_" + modelData + ".png"

            smooth: false
            mipmap: false
        }
    }
}