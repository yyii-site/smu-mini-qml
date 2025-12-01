import QtQuick
import QtQuick.Controls

Window {
    width: 960
    height: 600
    visible: true
    title: qsTr("Hello World")

    // 定时器正在使用串口标志
    property bool timerUsingSerial: false

    // 串口参数
    Rectangle {
        id: rect1
        width: 300
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

    // 通过串口发送指令的函数，避免与定时器冲突
    function serialSendCommand(msg) {
        while(myTimer.running && timerUsingSerial) {
            // 等待
        }
        myTimer.running = false
        serial.sendCommand(msg)
        myTimer.running = true
    }

    function serialSendAndRead(msg) {
        while(myTimer.running && timerUsingSerial) {
            // 等待
        }
        myTimer.running = false
        var response = serial.sendCommandAndReadResponse(msg)
        myTimer.running = true
        return response
    }

    function serialSendAndReadInTimer(msg) {
        var response = serial.sendCommandAndReadResponse(msg)
        return response
    }

    // SMU 工作模式
    Rectangle {
        id: rect2
        anchors.top: rect1.top
        anchors.left: rect1.right

        width: 100
        height: 150

        Text {
            id: rect2_name
            text: qsTr("SMU 工作模式")
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            SmuSetFunction {
                id: smuChannel0Function
                channelNum: 0
            }

            SmuSetFunction {
                id: smuChannel1Function
                channelNum: 1
            }

            SmuSetFunction {
                id: smuChannel2Function
                channelNum: 2
            }

            SmuSetFunction {
                id: smuChannel3Function
                channelNum: 3
            }
        }
    }

    // 当 SmuSetFunction 发出信号，槽函数通过串口发出指令
    Connections {
        target: smuChannel0Function
        function onFunctionChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel1Function
        function onFunctionChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel2Function
        function onFunctionChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel3Function
        function onFunctionChanged(msg) {
            serialSendCommand(msg)
        }
    }

    // SMU 目标电压电流
    Rectangle {
        id: rect3
        anchors.top: rect2.bottom
        anchors.left: rect2.left

        width: 100
        height: 150

        Text {
            id: rect3_name
            text: qsTr("SMU 目标电压电流")
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            SmuSetTarget {
                id: smuChannel0Target
                channelNum: 0
            }

            SmuSetTarget {
                id: smuChannel1Target
                channelNum: 1
            }

            SmuSetTarget {
                id: smuChannel2Target
                channelNum: 2
            }

            SmuSetTarget {
                id: smuChannel3Target
                channelNum: 3
            }
        }
    }
    Connections {
        target: smuChannel0Target
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel1Target
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel2Target
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel3Target
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }


    // SMU 保护电压电流
    Rectangle {
        id: rect4
        anchors.top: rect3.bottom
        anchors.left: rect3.left

        width: 200
        height: 150

        Text {
            id: rect4_name
            text: qsTr("SMU 目标电压电流")
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            SmuSetProtection {
                id: smuChannel0Protection
                channelNum: 0
            }

            SmuSetProtection {
                id: smuChannel1Protection
                channelNum: 1
            }

            SmuSetProtection {
                id: smuChannel2Protection
                channelNum: 2
            }

            SmuSetProtection {
                id: smuChannel3Protection
                channelNum: 3
            }
        }
    }
    Connections {
        target: smuChannel0Protection
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel1Protection
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel2Protection
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }
    Connections {
        target: smuChannel3Protection
        function onTargetChanged(msg) {
            serialSendCommand(msg)
        }
    }

    // 查询电流范围
    Rectangle {
        id: rect5
        height: 100
        anchors.top: rect1.bottom
        anchors.left: rect1.left
        // 发送模式查询指令并解析和显示返回状态
        // 显示当前电流范围

        Column {
            id: txt_current_range
            anchors.margins: 10
            Text {
                id: txt_current0_range
                text: "CH0 Range: "
            }
            Text {
                id: txt_current1_range
                text: "CH1 Range: "
            }
            Text {
                id: txt_current2_range
                text: "CH2 Range: "
            }
            Text {
                id: txt_current3_range
                text: "CH3 Range: "
            }
        }

        Button {
            id: btn_query_current_range
            anchors.top: txt_current_range.bottom
            anchors.left: parent.left
            text: "查询电流范围"
            width: 80
            anchors.margins: 5
            onClicked: {
                var range0 = serialSendAndRead(":CHANnel0:CURRent:RANGe?\r\n")
                console.log("Ch0 current range: " + range0)
                var range1 = serialSendAndRead(":CHANnel1:CURRent:RANGe?\r\n")
                console.log("Ch1 current range: " + range1)
                var range2 = serialSendAndRead(":CHANnel2:CURRent:RANGe?\r\n")
                console.log("Ch2 current range: " + range2)
                var range3 = serialSendAndRead(":CHANnel3:CURRent:RANGe?\r\n")
                console.log("Ch3 current range: " + range3)
                txt_current0_range.text = "CH0 Range:" + range0
                txt_current1_range.text = "CH1 Range:" + range1
                txt_current2_range.text = "CH2 Range:" + range2
                txt_current3_range.text = "CH3 Range:" + range3
            }
        }
    }

    // 定时器显示
    Rectangle {
        id: rect6
        width: 50
        height: 10
        anchors.top: rect4.bottom
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
            timerUsingSerial = true
            var buf = serialSendAndReadInTimer("FETCh?\r\n")
            timerUsingSerial = false
            if (buf === null || buf.length === 0) {
                return
            }
            console.log("Fetched Data: " + buf)
            voltageModel.clear() // 清空现有数据
            function formatVoltage(v) {
                v = v - 7535960
                v = v * 1.491210803524029e-6
                return v.toFixed(6) + " V"
            }
            // 2mA 档校准的系数
            function formatCurrent(i) {
                i = i - 7544410
                i = i * 2.991199535114993e-7
                return i.toFixed(6) + " mA"
            }

            var measurements = buf.split(",")
            for (var i = 0; i < measurements.length; i++) {
                var parts = measurements[i].match(/([A-Z]+)(-?\d+(\.\d+)?)/)
                if (parts && parts.length >= 3) {
                    var type = parts[1]
                    var value = parseFloat(parts[2])
                    console.log("ch:", i, "type:", type, "value:", value)
                    if (type.indexOf("MV") !== -1) {
                        voltageModel.append({ "string": "CH" + i + "_" + type + " Voltage: " + formatVoltage(value) })
                    } else if (type.indexOf("MI") !== -1) {
                        voltageModel.append({ "string": "CH" + i + "_" + type + " Current: " + formatCurrent(value) })
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
                    font.pointSize: 12
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
