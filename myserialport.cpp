#include "myserialport.h"
#include <QSerialPortInfo>
#include <QDateTime>

MySerialPort::MySerialPort(QObject *parent)
    : QObject{parent} {
    m_com = "COM5";
    m_baudRate = 115200;
    m_dataBit = 8;
    m_parity = "No";
    m_stopBit = 1;

    // 异步串口数据接收
    // connect(&m_serial, &QSerialPort::readyRead, this, [=]() {
    //     if (m_serial.canReadLine()) {
    //         //读取所有可用数据
    //         QByteArray data = m_serial.readAll();
    //         emit readData(data);
    //     }
    // });
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
    qDebug() << "serial sendCommand" << comm;
    if (!m_serial.isOpen()) {
        return;
    }

    QByteArray byteArray = comm.toUtf8();
    const char* cString = byteArray.constData();

    QMutexLocker lock(&m_mutex);
    m_serial.write(cString, strlen(cString));
    if (!m_serial.waitForBytesWritten(100)) {
        // 串口数据发送超时
    }
}

QString MySerialPort::sendCommandAndReadResponse(const QString comm, int timeoutMs) {
    if (!m_serial.isOpen()) {
        return QString();
    }

    QByteArray byteArray = comm.toUtf8();
    const char* cString = byteArray.constData();

    QMutexLocker lock(&m_mutex);
    m_serial.clear();
    m_serial.write(cString, strlen(cString));
    if (!m_serial.waitForBytesWritten(100)) {
        return QString();
    }

    QByteArray responseLine;
    qint64 startTime = QDateTime::currentMSecsSinceEpoch();
    while (QDateTime::currentMSecsSinceEpoch() - startTime < timeoutMs) {
        // 阻塞等待直到有数据可读 (不超过剩余超时时间)
        if (m_serial.waitForReadyRead(10)) { // 每次等待 100ms

            // 使用 readLine() 尝试读取直到 0x0A (或超时)
            if (m_serial.canReadLine()) {
                responseLine = m_serial.readLine(256); // 限制读取长度

                // 检查是否以 0x0A 结束 (readLine() 应该已经包含它)
                if (responseLine.endsWith('\n')) {
                    // 找到完整响应
                    return QString::fromUtf8(responseLine).trimmed();
                }
            }
        }
    }
    // 超时未读取到完整行
    return QString();
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
