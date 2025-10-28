import QtQuick
import QtQuick.Controls

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    // 定时器正在使用串口标志
    property bool timerUsingSerial: false

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

        // 使用 ComboBox 控件选择电流范围
        ComboBox {
            id: currentRangeCbb
            anchors.margins: 5
            width: 120
            model: ["80mA", "2mA", "200uA", "20uA", "5uA"]
            // 设置默认选中项
            Component.onCompleted: {
                currentRangeCbb.currentIndex = 1
            }
        }

        // 使用 ComboBox 控件选择工作模式
        ComboBox {
            id: modeCbb
            anchors.left: currentRangeCbb.right
            anchors.margins: 5
            width: 120
            model: ["HIZMV", "FVMI", "FIMV", "FVMV", "FIMI"]
            Component.onCompleted: {
                modeCbb.currentIndex = 0
            }
        }

        // 按下确定按钮发送当前设置
        Button {
            id: btn_func_set
            text: "确定"
            anchors.left: modeCbb.right
            anchors.margins: 5
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
                console.log("Selected current range in A: ", buf)
                // 发送设置电流范围指令
                var mode = modeCbb.currentText
                serial.sendCommand(":CHANnel0:FUNCtion \"" + mode + "\"," + buf + "\r\n")
            }
        }
    }

    // 查询电流范围
    Rectangle {
        id: rect3
        height: 50
        anchors.top: rect2.bottom
        // 发送模式查询指令并解析和显示返回状态
        Button {
            id: btn_query_current_range
            text: "查询电流范围"
            width: 80
            anchors.margins: 5
            // 显示当前电流范围
            Text {
                id: txt_current_range
                anchors.bottom: btn_query_current_range.bottom
                anchors.left: btn_query_current_range.right
                text: ""
            }
            onClicked: {
                // 等待定时器完成当前轮询
                while(myTimer.running && timerUsingSerial) {
                    // 等待
                }
                myTimer.running = false
                var range0 = serial.sendCommandAndReadResponse(":CHANnel0:CURRent:RANGe?\r\n")
                console.log("Current range: " + range0)
                var range1 = serial.sendCommandAndReadResponse(":CHANnel1:CURRent:RANGe?\r\n")
                console.log("Current range: " + range1)
                var range2 = serial.sendCommandAndReadResponse(":CHANnel2:CURRent:RANGe?\r\n")
                console.log("Current range: " + range2)
                var range3 = serial.sendCommandAndReadResponse(":CHANnel3:CURRent:RANGe?\r\n")
                console.log("Current range: " + range3)
                txt_current_range.text = "CH0:" + range0 + " CH1:" + range1 + " CH2:" + range2 + " CH3:" + range3
                myTimer.running = true
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
        running: false
        onTriggered: {
            rect6.color = (rect6.color == "#ff0000") ? "#0000ff" : "#ff0000"
            timerUsingSerial = true
            var buf = serial.sendCommandAndReadResponse("FETCh?\r\n")
            timerUsingSerial = false
            console.log("Fetched Data: " + buf)
            voltageModel.clear() // 清空现有数据
            function formatVoltage(v) {
                return 0.001*v.toFixed(6) + " V"
            }
            function formatCurrent(i) {
                return 0.001*i.toFixed(6) + " A"
            }

            var measurements = buf.split(",")
            for (var i = 0; i < measurements.length; i++) {
                var parts = measurements[i].match(/([A-Z]+)(-?\d+(\.\d+)?)/)
                if (parts && parts.length >= 3) {
                    var type = parts[1]
                    var value = parseFloat(parts[2])
                    console.log("ch:", i, "type:", type, "value:", value)
                    if (type.indexOf("MV") !== -1) {
                        voltageModel.append({ "string": "CH" + i + " Voltage: " + formatVoltage(value) })
                    } else if (type.indexOf("MI") !== -1) {
                        voltageModel.append({ "string": "CH" + i + " Current: " + formatCurrent(value) })
                    }
                }
             }
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

        // Connections {
        //     target: serial
        //     onReadData: data => {
        //         console.log(data)
        //         updateVoltages(String(data))
        //     }
        //     // 解析并更新电压电流值
        //     function updateVoltages(msg) {
        //         voltageModel.clear() // 清空现有数据
        //         var voltages = parseVoltages(msg) // 解析新的数据
        //         for (var i = 0; i < voltages.length; i++) {
        //             voltageModel.append({ "string": voltages[i] }) // 将新数据添加到模型
        //         }
        //     }

        //     function parseVoltages(msg) {
        //         var voltages = msg.split(",")
        //         var results = []
        //         for (var i = 0; i < voltages.length; i++) {
        //             var parts = voltages[i].split(":")
        //             var voltage = parseFloat(parts[1])
        //             results.push(formatVoltage(voltage))
        //         }
        //         return results
        //     }

        //     // 格式化电压值
        //     function formatVoltage(voltage) {
        //         if (voltage >= 1e6) {
        //             return (voltage / 1e6).toFixed(2) + " V"; // 转换为 V
        //         } else if (voltage >= 1e3) {
        //             return (voltage / 1e3).toFixed(2) + " mV"; // 转换为 mV
        //         } else {
        //             return voltage.toFixed(2) + " uV"; // 转换为 uV
        //         }
        //     }
        // }
    }


}
