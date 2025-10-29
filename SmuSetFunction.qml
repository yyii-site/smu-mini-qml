import QtQuick
import QtQuick.Controls

Item {
    anchors.margins: 10
    width: 200
    height:20

    property int channelNum: 0
    signal functionChanged(var msg);

    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            id: channelLabel
            text: "CH" + channelNum
        }

        // 使用 ComboBox 控件选择电流范围
        ComboBox {
            id: currentRangeCbb
            model: ["80mA", "2mA", "200uA", "20uA", "5uA"]
            // 设置默认选中项
            Component.onCompleted: {
                currentRangeCbb.currentIndex = 1
            }
        }

        // 使用 ComboBox 控件选择工作模式
        ComboBox {
            id: modeCbb
            model: ["HIZMV", "FVMI", "FIMV", "FVMV", "FIMI"]
            Component.onCompleted: {
                modeCbb.currentIndex = 0
            }
        }

        // 按下确定按钮发送当前设置
        Button {
            id: btn_func_set
            text: "确定"
            onClicked: {
                // 读取电流范围并将其转为浮点型
                var buf = currentRangeCbb.currentText
                if (buf.indexOf("uA") !== -1) {
                    buf = parseFloat(buf) * 1e-6
                    buf = buf.toFixed(6)
                } else if (currentRangeCbb.currentText.indexOf("mA") !== -1) {
                    buf = parseFloat(buf) * 1e-3
                    buf = buf.toFixed(3)
                } else {
                    buf = parseFloat(buf)
                    buf = buf.toFixed(1)
                }
                var msg = ":CHANnel" + channelNum + ":FUNCtion \"" + modeCbb.currentText + "\"," + buf
                console.log(msg)
                functionChanged(msg + "\r\n")
            }
        }
    }
}
