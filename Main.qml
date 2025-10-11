import QtQuick
import QtQuick.Controls

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    // 串口参数
    Rectangle {
        id: rect1
        width: 200
        height: 200

        // 串口号
        ComboBox {
            id: comCbb
            model: ListModel {
                id: comModel
            }
            textRole: "COM"

            onPressedChanged: {
                var nowIndex = comCbb.currentIndex
                updateCom()
                comCbb.currentIndex = nowIndex
            }

            // 刷新可用串口
            function updateCom() {
                var comList = serial.availableList()
                comModel.clear()
                for (var i = 0; i < comList.length; i++) {
                    comModel.append({
                                        "COM": comList[i]
                                    })
                }
            }

            onActivated: index => {
                             serial.com = currentText
                         }

            Component.onCompleted: {
                updateCom()
                comCbb.currentIndex = 0
            }
        }

        // 波特率
        ComboBox {
            id: baudRateCbb
            anchors.top: comCbb.bottom
            model: ListModel {
                ListElement {
                    baudRate: 9600
                }
                ListElement {
                    baudRate: 115200
                }
                ListElement {
                    baudRate: 2000000
                }
            }
            textRole: "baudRate"

            onActivated: index => {
                             serial.baudRate = currentText
                         }

            Component.onCompleted: {
                baudRateCbb.currentIndex = 1
            }
        }

        // 数据位
        ComboBox {
            id: dataBitCbb
            anchors.top: baudRateCbb.bottom
            model: ListModel {
                ListElement {
                    dataBit: 7
                }
                ListElement {
                    dataBit: 8
                }
            }
            textRole: "dataBit"

            onActivated: index => {
                             serial.dataBit = currentText
                         }

            Component.onCompleted: {
                dataBitCbb.currentIndex = 1
            }
        }

        // 校验位
        ComboBox {
            id: parityCbb
            anchors.top: dataBitCbb.bottom
            model: ListModel {
                ListElement {
                    parity: "No"
                }
                ListElement {
                    parity: "Even"
                }
                ListElement {
                    parity: "Odd"
                }
            }
            textRole: "parity"

            onActivated: index => {
                             serial.parity = currentText
                         }

            Component.onCompleted: {
                parityCbb.currentIndex = 0
            }
        }

        // 停止位
        ComboBox {
            id: stopBitCbb
            anchors.top: parityCbb.bottom
            model: ListModel {
                ListElement {
                    stopBit: 1
                }
                ListElement {
                    stopBit: 1.5
                }
                ListElement {
                    stopBit: 2
                }
            }
            textRole: "stopBit"

            onActivated: index => {
                             serial.stopBit = currentText
                         }

            Component.onCompleted: {
                stopBitCbb.currentIndex = 0
            }
        }

        // 连接
        Button {
            id: openBtn
            anchors.top: stopBitCbb.bottom
            text: "连接"
            onClicked: {
                if (serial.open()) {
                    openBtn.enabled = false
                    comCbb.enabled = false
                    baudRateCbb.enabled = false
                    dataBitCbb.enabled = false
                    parityCbb.enabled = false
                    stopBitCbb.enabled = false
                }
            }
        }

        // 断连
        Button {
            id: closeBtn
            anchors.top: stopBitCbb.bottom
            anchors.left: openBtn.right
            text: "断连"
            onClicked: {
                serial.close()
                openBtn.enabled = true
                comCbb.enabled = true
                baudRateCbb.enabled = true
                dataBitCbb.enabled = true
                parityCbb.enabled = true
                stopBitCbb.enabled = true
            }
        }

        Component.onCompleted: {
            console.log(serial.com, serial.baudRate, serial.dataBit,
                        serial.parity, serial.stopBit)
            console.log(serial.availableList())
        }

        Button {
            id: btn_start
            anchors.top: openBtn.bottom
            text: "启动"
            onClicked: {
                serial.startPlot()
            }
        }

        Button {
            anchors.top: openBtn.bottom
            anchors.left: btn_start.right
            text: "停止"
            onClicked: {
                serial.stopPlot()
            }
        }
    }

    // SMU 工作模式
    Rectangle {
        id: rect2
        height: 50
        anchors.top: rect1.bottom

        // 工作模式
        Button {
            id: btn_hizmv
            text: "HIZMV"
            width: 60
            onClicked: {
                serial.sendCommand(":CHANnel0:FUNCtion \"HIZMVI\"\r\n")
            }
        }
        Button {
            id: btn_fvmi
            text: "FVMI"
            width: 60
            anchors.left: btn_hizmv.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:FUNCtion \"FVMI\"\r\n")
            }
        }
        Button {
            id: btn_fimv
            text: "FIMV"
            width: 60
            anchors.left: btn_fvmi.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:FUNCtion \"FIMV\"\r\n")
            }
        }
        Button {
            id: btn_fvmv
            text: "FVMV"
            width: 60
            anchors.left: btn_fimv.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:FUNCtion \"FVMV\"\r\n")
            }
        }
        Button {
            id: btn_fimi
            text: "FIMI"
            width: 60
            anchors.left: btn_fvmv.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:FUNCtion \"FIMI\"\r\n")
            }
        }
    }

    // SMU 电流范围
    Rectangle {
        id: rect3
        height: 50
        anchors.top: rect2.bottom

        // 电流范围
        Button {
            id: btn_range_80mA
            text: "Ext 80mA"
            width: 60
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:CURRent:RANGe 80e-3\r\n")
            }
        }
        Button {
            id: btn_range_2mA
            text: "2mA"
            width: 60
            anchors.left: btn_range_80mA.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:CURRent:RANGe 2e-3\r\n")
            }
        }
        Button {
            id: btn_range_200uA
            text: "200uA"
            width: 60
            anchors.left: btn_range_2mA.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:CURRent:RANGe 200e-6\r\n")
            }
        }
        Button {
            id: btn_range_20uA
            text: "20uA"
            width: 60
            anchors.left: btn_range_200uA.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:CURRent:RANGe 20e-6\r\n")
            }
        }
        Button {
            id: btn_range_5uA
            text: "5uA"
            width: 60
            anchors.left: btn_range_20uA.right
            anchors.margins: 5
            onClicked: {
                serial.sendCommand(":CHANnel0:CURRent:RANGe 5e-6\r\n")
            }
        }
    }

    // 目标电压设置
    Rectangle {
        id: rect4
        width: 200
        height: 50
        anchors.top: rect3.bottom
        TextField {
            id: num_voltage
            width: 50
            anchors.margins: 5
            placeholderText: "Voltage"
            validator: DoubleValidator {
                bottom: -10.0
                top: 10.0
            }

            onTextChanged: {
                // 处理输入变化
                if (text.length > 0) {
                    let value = parseFloat(text)
                    if (!isNaN(value)) {
                        console.log("Current float value: ", value)
                    } else {
                        console.log("Invalid float input")
                    }
                }
            }
        }
        Button {
            id: btn_voltage
            text: "目标电压V"
            width: 80
            anchors.left: num_voltage.right
            anchors.margins: 5
            onClicked: {
                if (num_voltage.text.length > 0) {
                    let value = parseFloat(num_voltage.text)
                    if (!isNaN(value)) {
                        console.log("Current float value: ", value)
                        serial.sendCommand(
                                    ":CHANnel0:VOLTage:LEVel " + value + " \r\n")
                    } else {
                        console.log("Invalid float input")
                    }
                }
            }
        }
    }

    // 目标电流设置
    Rectangle {
        id: rect5
        width: 200
        height: 50
        anchors.top: rect4.top
        anchors.left: rect4.right
        TextField {
            id: num_current
            width: 50
            anchors.margins: 5
            placeholderText: "Current"
            validator: DoubleValidator {
                bottom: 0.0
                top: 100.0
            }

            onTextChanged: {
                // 处理输入变化
                if (text.length > 0) {
                    let value = parseFloat(text)
                    if (!isNaN(value)) {
                        console.log("Current float value: ", value)
                    } else {
                        console.log("Invalid float input")
                    }
                }
            }
        }
        Button {
            id: btn_current
            text: "目标电流A"
            width: 80
            anchors.left: num_current.right
            anchors.margins: 5
            onClicked: {
                if (num_current.text.length > 0) {
                    let value = parseFloat(num_current.text)
                    if (!isNaN(value)) {
                        console.log("Current float value: ", value)
                        serial.sendCommand(
                                    ":CHANnel0:CURRent:LEVel " + value + " \r\n")
                    } else {
                        console.log("Invalid float input")
                    }
                }
            }
        }
    }

    // 定时器显示
    Rectangle {
        id: rect6
        width: 50
        height: 10
        anchors.top: rect5.bottom
        visible: false
    }

    // 定时查询
    Timer {
        id: myTimer
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            rect6.color = (rect6.color == "#ff0000") ? "#0000ff" : "#ff0000"
            serial.sendCommand(":CHANnel0:FETCh?\r\n")
        }
    }

    Rectangle {
        id: rect7
        anchors.top: rect6.bottom


        // 用于存储电压显示的模型
        ListModel {
            id: voltageModel
        }

        Column {
            // anchors.centerIn: parent

            // 显示电压值
            Repeater {
                model: voltageModel
                delegate: Text {
                    text: modelData
                    font.pointSize: 15
                    padding: 2
                }
            }
        }

        Connections {
            target: serial
            onReadData: data => {
                // console.log(data)
                updateVoltages(String(data))
            }
            // 解析并更新电压电流值
            function updateVoltages(msg) {
                voltageModel.clear() // 清空现有数据
                var voltages = parseVoltages(msg) // 解析新的数据
                for (var i = 0; i < voltages.length; i++) {
                    voltageModel.append({ "string": voltages[i] }) // 将新数据添加到模型
                }
            }

            function parseVoltages(msg) {
                var voltages = msg.split(",")
                var results = []
                for (var i = 0; i < voltages.length; i++) {
                    var parts = voltages[i].split(":")
                    var voltage = parseFloat(parts[1])
                    results.push(formatVoltage(voltage))
                }
                return results
            }

            // 格式化电压值
            function formatVoltage(voltage) {
                if (voltage >= 1e6) {
                    return (voltage / 1e6).toFixed(2) + " V"; // 转换为 V
                } else if (voltage >= 1e3) {
                    return (voltage / 1e3).toFixed(2) + " mV"; // 转换为 mV
                } else {
                    return voltage.toFixed(2) + " uV"; // 转换为 uV
                }
            }
        }
    }
}
