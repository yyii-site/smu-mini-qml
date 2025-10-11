#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "myserialport.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
    []() {
        QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("serial", new MySerialPort);
    engine.loadFromModule("smu_mini_qt", "Main");

    return app.exec();
}
