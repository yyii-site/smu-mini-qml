import QtQuick
import QtQuick.Controls

Item {
    anchors.margins: 10
    width: 200
    height:20

    property int channelNum: 0
    signal targetChanged(var msg);
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Text {
            id: channelLabel
            text: "CH" + channelNum
        }

        Text {
            text: "V_high:"
        }
        TextField {
            id: num_voltage_high
            width: 50
            anchors.margins: 5
            placeholderText: "电压高限"
            validator: DoubleValidator {
                bottom: -11.0
                top: 11.0
            }
        }
        Button {
            id: btn_v_high_set
            text: "确定"
            onClicked: {
                let value = parseFloat(num_voltage_high.text)
                if (!isNaN(value)) {
                    var msg = ":CHANnel" + channelNum + ":VOLTage:PROTection:UPPer " + num_voltage_high.text
                    console.log(msg)
                    targetChanged(msg + "\r\n")
                } else {
                    console.log("Invalid float input")
                }
            }
        }

        Text {
            text: "V_low:"
        }
        TextField {
            id: num_voltage_low
            width: 50
            anchors.margins: 5
            placeholderText: "电压低限"
            validator: DoubleValidator {
                bottom: -10.0
                top: 10.0
            }
        }
        Button {
            id: btn_v_low_set
            text: "确定"
            onClicked: {
                let value = parseFloat(num_voltage_low.text)
                if (!isNaN(value)) {
                    var msg = ":CHANnel" + channelNum + ":VOLTage:PROTection:LOWer " + num_voltage_low.text
                    console.log(msg)
                    targetChanged(msg + "\r\n")
                } else {
                    console.log("Invalid float input")
                }
            }
        }

        Text {
            text: "I_high:"
        }
        TextField {
            id: num_current_high
            width: 50
            anchors.margins: 5
            placeholderText: "电流高限"
            validator: DoubleValidator {
                bottom: -10.0
                top: 10.0
            }
        }
        Button {
            id: btn_i_high_set
            text: "确定"
            onClicked: {
                let value = parseFloat(num_current_high.text)
                if (!isNaN(value)) {
                    var msg = ":CHANnel" + channelNum + ":CURRent:PROTection:UPPer " + num_current_high.text
                    console.log(msg)
                    targetChanged(msg + "\r\n")
                } else {
                    console.log("Invalid float input")
                }
            }
        }

        Text {
            text: "I_low:"
        }
        TextField {
            id: num_current_low
            width: 50
            anchors.margins: 5
            placeholderText: "电压低限"
            validator: DoubleValidator {
                bottom: -10.0
                top: 10.0
            }
        }
        Button {
            id: btn_i_low_set
            text: "确定"
            onClicked: {
                let value = parseFloat(num_current_low.text)
                if (!isNaN(value)) {
                    var msg = ":CHANnel" + channelNum + ":CURRent:PROTection:LOWer " + num_current_low.text
                    console.log(msg)
                    targetChanged(msg + "\r\n")
                } else {
                    console.log("Invalid float input")
                }
            }
        }
    }
}
