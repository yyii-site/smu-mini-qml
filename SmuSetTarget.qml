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
            id: channelLabelV
            text: "V:"
        }

        TextField {
            id: num_voltage
            width: 50
            anchors.margins: 5
            placeholderText: "目标电压"
            validator: DoubleValidator {
                bottom: -10.0
                top: 10.0
            }
        }
        Button {
            id: btn_v_set
            text: "确定"
            onClicked: {
                let value = parseFloat(num_voltage.text)
                if (!isNaN(value)) {
                    var msg = ":CHANnel" + channelNum + ":VOLTage:LEVel " + num_voltage.text
                    console.log(msg)
                    targetChanged(msg + "\r\n")
                } else {
                    console.log("Invalid float input")
                }
            }
        }

        Text {
            id: channelLabelI
            text: "I:"
        }

        TextField {
            id: num_current
            width: 50
            anchors.margins: 5
            placeholderText: "目标电流"
            validator: DoubleValidator {
                bottom: -10.0
                top: 10.0
            }
        }
        Button {
            id: btn_c_set
            text: "确定"
            onClicked: {
                let value = parseFloat(num_current.text)
                if (!isNaN(value)) {
                    var msg = ":CHANnel" + channelNum + ":CURRent:LEVel " + num_current.text
                    console.log(msg)
                    targetChanged(msg + "\r\n")
                } else {
                    console.log("Invalid float input")
                }
            }
        }
    }
}
