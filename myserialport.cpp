#include "myserialport.h"
#include <QSerialPortInfo>

MySerialPort::MySerialPort(QObject *parent)
    : QObject{parent} {
    m_com = "COM5";
    m_baudRate = 115200;
    m_dataBit = 8;
    m_parity = "No";
    m_stopBit = 1;

    // 数据接收
    connect(&m_serial, &QSerialPort::readyRead, this, [=]() {
        if (m_serial.canReadLine()) {
            //读取所有可用数据
            QByteArray data = m_serial.readAll();
            emit readData(data);
        }
    });
}

QStringList MySerialPort::availableList() {
    QStringList comList;
    foreach (const QSerialPortInfo &serialInfo, QSerialPortInfo::availablePorts()) {
        comList << serialInfo.portName();
    }
    return comList;
}

bool MySerialPort::open() {
    m_serial.setPortName(m_com);
    m_serial.setBaudRate(m_baudRate);
    QSerialPort::DataBits dataBits = QSerialPort::Data8;
    switch(m_dataBit) {
    case 7:
        dataBits = QSerialPort::Data7;
        break;
    case 8:
        dataBits = QSerialPort::Data8;
        break;
    default:
        dataBits = QSerialPort::Data8;
        break;
    }
    m_serial.setDataBits(dataBits);

    QSerialPort::Parity paritys = QSerialPort::NoParity;
    if (!m_parity.compare("No")) {
        paritys = QSerialPort::NoParity;
    } else if(!m_parity.compare("Even")) {
        paritys = QSerialPort::EvenParity;
    } else if(!m_parity.compare("Odd")) {
        paritys = QSerialPort::OddParity;
    }
    m_serial.setParity(paritys);

    QSerialPort::StopBits stopBits = QSerialPort::OneStop;
    if (m_stopBit == 1) {
        stopBits = QSerialPort::OneStop;
    } else if(m_stopBit == 1.5) {
        stopBits = QSerialPort::OneAndHalfStop;
    } else if(m_stopBit == 2) {
        stopBits = QSerialPort::TwoStop;
    }
    m_serial.setStopBits(stopBits);

    if (m_serial.open(QIODevice::ReadWrite)) {
        return true;
    }
    return false;
}

void MySerialPort::close() {
    if (m_serial.isOpen()) {
        m_serial.close();
    }
}

void MySerialPort::startPlot() {

}

void MySerialPort::stopPlot() {

}

void MySerialPort::sendCommand(const QString comm) {
    QByteArray byteArray = comm.toUtf8();
    const char* cString = byteArray.constData();
    writeData(cString, strlen(cString));
}

QString MySerialPort::com() const {
    return m_com;
}

void MySerialPort::setCom(const QString &newCom) {
    if (m_com == newCom)
        return;
    m_com = newCom;
    emit comChanged();
}

int MySerialPort::baudRate() const {
    return m_baudRate;
}

void MySerialPort::setBaudRate(int newBaudRate) {
    if (m_baudRate == newBaudRate)
        return;
    m_baudRate = newBaudRate;
    emit baudRateChanged();
}

int MySerialPort::dataBit() const {
    return m_dataBit;
}

void MySerialPort::setDataBit(int newDataBit) {
    if (m_dataBit == newDataBit)
        return;
    m_dataBit = newDataBit;
    emit dataBitChanged();
}

QString MySerialPort::parity() const {
    return m_parity;
}

void MySerialPort::setParity(const QString &newParity) {
    if (m_parity == newParity)
        return;
    m_parity = newParity;
    emit parityChanged();
}

float MySerialPort::stopBit() const {
    return m_stopBit;
}

void MySerialPort::setStopBit(float newStopBit) {
    if (qFuzzyCompare(m_stopBit, newStopBit))
        return;
    m_stopBit = newStopBit;
    emit stopBitChanged();
}

bool MySerialPort::writeData(const char *data, int len) {
    QMutexLocker lock(&m_mutex);
    if (!m_serial.isOpen()) {
        // 串口未打开
        return false;
    }
    m_serial.write(data, len);
    if (!m_serial.waitForBytesWritten(100)) {
        // 串口数据发送超时
        return false;
    }
    return true;
}
