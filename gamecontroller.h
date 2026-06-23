#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>
#include <QVariantList>
#include <QPoint>
#include <QTimer>

class GameController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(int columns READ columns NOTIFY fieldChanged)
    Q_PROPERTY(int rows READ rows NOTIFY fieldChanged)
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)

    Q_PROPERTY(QVariantList snake READ snake NOTIFY snakeChanged)
    Q_PROPERTY(QVariantList previousSnake READ previousSnake NOTIFY previousSnakeChanged)
    Q_PROPERTY(double moveProgress READ moveProgress NOTIFY moveProgressChanged)
    Q_PROPERTY(QVariantMap apple READ apple NOTIFY appleChanged)
    Q_PROPERTY(QVariantList obstacles READ obstacles NOTIFY obstaclesChanged)

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)
    Q_PROPERTY(bool gameOver READ gameOver NOTIFY gameOverChanged)

public:
    explicit GameController(QObject *parent = nullptr);

    int score() const;
    int columns() const;
    int rows() const;
    int speed() const;

    QVariantList snake() const;
    QVariantList previousSnake() const;
    double moveProgress() const;
    QVariantMap apple() const;
    QVariantList obstacles() const;

    bool running() const;
    bool paused() const;
    bool gameOver() const;

    Q_INVOKABLE void startGame(const QString &difficulty);
    Q_INVOKABLE void restartGame();
    Q_INVOKABLE void pauseGame();
    Q_INVOKABLE void resumeGame();
    Q_INVOKABLE void stopGame();

    Q_INVOKABLE void moveUp();
    Q_INVOKABLE void moveDown();
    Q_INVOKABLE void moveLeft();
    Q_INVOKABLE void moveRight();

signals:
    void scoreChanged();
    void fieldChanged();
    void speedChanged();

    void snakeChanged();
    void previousSnakeChanged();
    void moveProgressChanged();
    void appleChanged();
    void obstaclesChanged();

    void runningChanged();
    void pausedChanged();
    void gameOverChanged();

private slots:
    void updateGame();
    void updateMoveAnimation();

private:
    enum Direction {
        Up,
        Down,
        Left,
        Right
    };

    void setupDifficulty(const QString &difficulty);
    void resetSnake();
    void generateApple();
    void generateObstacles(int count);
    void finishGame();

    bool pointInSnake(const QPoint &point) const;
    bool pointInObstacles(const QPoint &point) const;
    bool pointIsFree(const QPoint &point) const;

    int normalizedDelta(int delta, int size) const;

    QString headSprite() const;
    QString bodySprite(int index) const;
    QString tailSprite() const;

    QVariantMap makeSnakeSegment(int index) const;

private:
    int m_score;
    int m_columns;
    int m_rows;
    int m_speed;
    int m_pointsPerApple;
    int m_growPerApple;

    bool m_wrapWalls;
    bool m_running;
    bool m_paused;
    bool m_gameOver;

    Direction m_direction;
    Direction m_nextDirection;

    QVector<QPoint> m_snake;
    QVector<QPoint> m_previousSnake;
    double m_moveProgress;
    QTimer m_animationTimer;
    QPoint m_apple;
    QVector<QPoint> m_obstacles;

    int m_growLeft;

    QString m_currentDifficulty;

    QTimer m_timer;
};

#endif