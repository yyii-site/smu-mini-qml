#ifndef MYSERIALPORT_H
#define MYSERIALPORT_H

#include <QObject>
#include <QSerialPort>
#include <QMutex>


class MySerialPort : public QObject {
    Q_OBJECT
    // 串口号
    Q_PROPERTY(QString com READ com WRITE setCom NOTIFY comChanged FINAL)
    // 波特率
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged FINAL)
    // 数据位
    Q_PROPERTY(int dataBit READ dataBit WRITE setDataBit NOTIFY dataBitChanged FINAL)
    // 校验位
    Q_PROPERTY(QString parity READ parity WRITE setParity NOTIFY parityChanged FINAL)
    // 停止位
    Q_PROPERTY(float stopBit READ stopBit WRITE setStopBit NOTIFY stopBitChanged FINAL)

  public:
    explicit MySerialPort(QObject *parent = nullptr);

    // 搜索可用串口
    Q_INVOKABLE QStringList availableList(void);
    // 打开串口
    Q_INVOKABLE bool open(void);
    // 关闭串口
    Q_INVOKABLE void close(void);
    // 指令
    Q_INVOKABLE void startPlot(void);
    Q_INVOKABLE void stopPlot(void);
    Q_INVOKABLE void sendCommand(const QString comm);
    Q_INVOKABLE QString sendCommandAndReadResponse(const QString comm, int timeoutMs = 100);

    QString com() const;
    void setCom(const QString &newCom);

    int baudRate() const;
    void setBaudRate(int newBaudRate);

    int dataBit() const;
    void setDataBit(int newDataBit);

    QString parity() const;
    void setParity(const QString &newParity);

    float stopBit() const;
    void setStopBit(float newStopBit);

  signals:
    void comChanged();
    void baudRateChanged();
    void dataBitChanged();
    void parityChanged();
    void stopBitChanged();

    // 读数据
    void readData(QByteArray data);

  private:
    QMutex m_mutex;
    QSerialPort m_serial;
    QString m_com;
    int m_baudRate;
    int m_dataBit;
    QString m_parity;
    float m_stopBit;
};

#endif // MYSERIALPORT_H
