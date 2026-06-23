#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "gamecontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("SnakeProject");
    QCoreApplication::setApplicationName("Snake");

    qmlRegisterType<GameController>("Snake.Game", 1, 0, "GameController");

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
        );

    engine.loadFromModule("Snake", "Main");

    return QCoreApplication::exec();
}