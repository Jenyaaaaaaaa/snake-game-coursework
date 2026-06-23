#include "gamecontroller.h"

#include <QRandomGenerator>
#include <QtGlobal>

GameController::GameController(QObject *parent)
    : QObject(parent),
    m_score(0),
    m_columns(15),
    m_rows(15),
    m_speed(180),
    m_pointsPerApple(2),
    m_growPerApple(1),
    m_wrapWalls(false),
    m_running(false),
    m_paused(false),
    m_gameOver(false),
    m_direction(Right),
    m_nextDirection(Right),
    m_apple(0, 0),
    m_growLeft(0),
    m_moveProgress(1.0),
    m_currentDifficulty("normal")
{
    //таймер рухає змійку з певною швид.
    connect(&m_timer, &QTimer::timeout,
            this, &GameController::updateGame);

    m_timer.setInterval(m_speed);

    //плавність руху між клітинками
    connect(&m_animationTimer, &QTimer::timeout,
            this, &GameController::updateMoveAnimation);

    m_animationTimer.setInterval(16);
}

int GameController::score() const
{
    return m_score;
}

int GameController::columns() const
{
    return m_columns;
}

int GameController::rows() const
{
    return m_rows;
}

int GameController::speed() const
{
    return m_speed;
}

QVariantList GameController::snake() const
{
    QVariantList result;

    for (int i = 0; i < m_snake.size(); ++i)
        result.append(makeSnakeSegment(i));

    return result;
}

QVariantList GameController::previousSnake() const
{
    QVariantList result;

    for (const QPoint &point : m_previousSnake) {
        result.append(QVariantMap {
            { "x", point.x() },
            { "y", point.y() }
        });
    }

    return result;
}

double GameController::moveProgress() const
{
    return m_moveProgress;
}

QVariantMap GameController::apple() const
{
    return {
        { "x", m_apple.x() },
        { "y", m_apple.y() }
    };
}

QVariantList GameController::obstacles() const
{
    QVariantList result;

    QStringList sprites = {
        "stone.png",
        "bush.png",
        "stump.png"
    };

    for (int i = 0; i < m_obstacles.size(); ++i) {
        const QPoint &point = m_obstacles.at(i);

        result.append(QVariantMap {
            { "x", point.x() },
            { "y", point.y() },
            { "sprite", sprites.at(i % sprites.size()) }
        });
    }

    return result;
}

bool GameController::running() const
{
    return m_running;
}

bool GameController::paused() const
{
    return m_paused;
}

bool GameController::gameOver() const
{
    return m_gameOver;
}

void GameController::startGame(const QString &difficulty)
{
    m_currentDifficulty = difficulty;

    setupDifficulty(difficulty);

    m_score = 0;
    m_growLeft = 0;
    m_running = true;
    m_paused = false;
    m_gameOver = false;

    resetSnake();

    m_previousSnake = m_snake;
    m_moveProgress = 1.0;

    int obstacleCount = 0;

    if (difficulty == "normal")
        obstacleCount = 3;
    else if (difficulty == "hard")
        obstacleCount = 5;

    generateObstacles(obstacleCount);
    generateApple();

    m_timer.setInterval(m_speed);
    m_timer.start();

    emit scoreChanged();
    emit fieldChanged();
    emit speedChanged();
    emit snakeChanged();
    emit obstaclesChanged();
    emit appleChanged();
    emit runningChanged();
    emit pausedChanged();
    emit gameOverChanged();
    emit previousSnakeChanged();
    emit moveProgressChanged();
}

void GameController::restartGame()
{
    startGame(m_currentDifficulty);
}

void GameController::pauseGame()
{
    if (!m_running || m_gameOver)
        return;

    m_paused = true;
    m_timer.stop();
    m_animationTimer.stop();

    emit pausedChanged();
}

void GameController::resumeGame()
{
    if (!m_running || m_gameOver)
        return;

    m_paused = false;
    m_timer.start();

    if (m_moveProgress < 1.0)
        m_animationTimer.start();

    emit pausedChanged();
}

void GameController::stopGame()
{
    m_timer.stop();

    m_running = false;
    m_paused = false;
    m_animationTimer.stop();

    emit runningChanged();
    emit pausedChanged();
}

void GameController::moveUp()
{
    if (m_direction != Down)
        m_nextDirection = Up;
}

void GameController::moveDown()
{
    if (m_direction != Up)
        m_nextDirection = Down;
}

void GameController::moveLeft()
{
    if (m_direction != Right)
        m_nextDirection = Left;
}

void GameController::moveRight()
{
    if (m_direction != Left)
        m_nextDirection = Right;
}

void GameController::updateGame()
{
    if (!m_running || m_paused || m_gameOver)
        return;

    m_previousSnake = m_snake;
    m_moveProgress = 0.0;

    emit previousSnakeChanged();
    emit moveProgressChanged();

    m_direction = m_nextDirection;

    QPoint head = m_snake.first();
    QPoint newHead = head;

    if (m_direction == Up)
        newHead.ry() -= 1;
    else if (m_direction == Down)
        newHead.ry() += 1;
    else if (m_direction == Left)
        newHead.rx() -= 1;
    else if (m_direction == Right)
        newHead.rx() += 1;

    //стіни як портал на легкому рівні
    if (m_wrapWalls) {
        if (newHead.x() < 0)
            newHead.setX(m_columns - 1);
        else if (newHead.x() >= m_columns)
            newHead.setX(0);

        if (newHead.y() < 0)
            newHead.setY(m_rows - 1);
        else if (newHead.y() >= m_rows)
            newHead.setY(0);
    } else {
        if (newHead.x() < 0 || newHead.x() >= m_columns
            || newHead.y() < 0 || newHead.y() >= m_rows) {
            finishGame();
            return;
        }
    }

    //зіткнення з тілом або перешкодою
    if (pointInSnake(newHead) || pointInObstacles(newHead)) {
        finishGame();
        return;
    }

    m_snake.prepend(newHead);

    //з'їла яблуко
    if (newHead == m_apple) {
        m_score += m_pointsPerApple;
        m_growLeft += m_growPerApple;

        generateApple();

        emit scoreChanged();
        emit appleChanged();
    }

    if (m_growLeft > 0)
        m_growLeft--;
    else
        m_snake.removeLast();

    m_animationTimer.start();

    emit snakeChanged();
}

void GameController::updateMoveAnimation()
{
    if (!m_running || m_paused || m_gameOver)
        return;

    double step = 16.0 / static_cast<double>(m_speed);

    m_moveProgress += step;

    if (m_moveProgress >= 1.0) {
        m_moveProgress = 1.0;
        m_animationTimer.stop();
    }

    emit moveProgressChanged();
}

void GameController::setupDifficulty(const QString &difficulty)
{
    if (difficulty == "easy") {
        m_columns = 19;
        m_rows = 13;
        m_speed = 220;
        m_pointsPerApple = 1;
        m_growPerApple = 1;
        m_wrapWalls = true;
    } else if (difficulty == "hard") {
        m_columns = 17;
        m_rows = 12;
        m_speed = 110;
        m_pointsPerApple = 1;
        m_growPerApple = 2;
        m_wrapWalls = false;
    } else {
        m_columns = 19;
        m_rows = 13;
        m_speed = 160;
        m_pointsPerApple = 1;
        m_growPerApple = 1;
        m_wrapWalls = false;
    }
}

void GameController::resetSnake()
{
    m_snake.clear();

    int startX = m_columns / 2;
    int startY = m_rows / 2;

    m_direction = Right;
    m_nextDirection = Right;

    m_snake.append(QPoint(startX, startY));
    m_snake.append(QPoint(startX - 1, startY));
    m_snake.append(QPoint(startX - 2, startY));
    m_snake.append(QPoint(startX - 3, startY));
}

void GameController::generateApple()
{
    QPoint point;

    do {
        int x = QRandomGenerator::global()->bounded(m_columns);
        int y = QRandomGenerator::global()->bounded(m_rows);

        point = QPoint(x, y);
    } while (!pointIsFree(point));

    m_apple = point;
}

void GameController::generateObstacles(int count)
{
    m_obstacles.clear();

    while (m_obstacles.size() < count) {
        int x = QRandomGenerator::global()->bounded(m_columns);
        int y = QRandomGenerator::global()->bounded(m_rows);

        QPoint point(x, y);

        //близько до старту змійки перешкоди не ставляться
        QPoint start(m_columns / 2, m_rows / 2);

        if (qAbs(point.x() - start.x()) < 3
            && qAbs(point.y() - start.y()) < 3)
            continue;

        if (pointIsFree(point))
            m_obstacles.append(point);
    }
}

void GameController::finishGame()
{
    m_timer.stop();
    m_animationTimer.stop();

    m_previousSnake = m_snake;
    m_moveProgress = 1.0;

    m_running = false;
    m_paused = false;
    m_gameOver = true;

    emit previousSnakeChanged();
    emit moveProgressChanged();
    emit snakeChanged();

    emit runningChanged();
    emit pausedChanged();
    emit gameOverChanged();
}

bool GameController::pointInSnake(const QPoint &point) const
{
    return m_snake.contains(point);
}

bool GameController::pointInObstacles(const QPoint &point) const
{
    return m_obstacles.contains(point);
}

bool GameController::pointIsFree(const QPoint &point) const
{
    return !pointInSnake(point)
    && !pointInObstacles(point);
}

QString GameController::headSprite() const
{
    if (m_direction == Up)
        return "head_up.png";
    if (m_direction == Down)
        return "head_down.png";
    if (m_direction == Left)
        return "head_left.png";

    return "head_right.png";
}

int GameController::normalizedDelta(int delta, int size) const
{
    if (!m_wrapWalls)
        return delta;

    if (delta > 1)
        delta -= size;
    else if (delta < -1)
        delta += size;

    return delta;
}

QString GameController::tailSprite() const
{
    if (m_snake.size() < 2)
        return "tail_left.png";

    QPoint tail = m_snake.last();
    QPoint beforeTail = m_snake.at(m_snake.size() - 2);

    int dx = normalizedDelta(beforeTail.x() - tail.x(), m_columns);
    int dy = normalizedDelta(beforeTail.y() - tail.y(), m_rows);

    //назва хвоста - куди дивиться кінчик хвоста
    if (dx > 0)
        return "tail_left.png";
    if (dx < 0)
        return "tail_right.png";
    if (dy > 0)
        return "tail_up.png";

    return "tail_down.png";
}

QString GameController::bodySprite(int index) const
{
    QPoint previous = m_snake.at(index - 1);
    QPoint current = m_snake.at(index);
    QPoint next = m_snake.at(index + 1);

    int dx1 = normalizedDelta(previous.x() - current.x(), m_columns);
    int dy1 = normalizedDelta(previous.y() - current.y(), m_rows);

    int dx2 = normalizedDelta(next.x() - current.x(), m_columns);
    int dy2 = normalizedDelta(next.y() - current.y(), m_rows);

    //горизонтальна лінія
    if (dy1 == 0 && dy2 == 0)
        return "body_horizontal.png";

    //вертикальна
    if (dx1 == 0 && dx2 == 0)
        return "body_vertical.png";

    //кутові частини
    bool connectsUp = dy1 < 0 || dy2 < 0;
    bool connectsDown = dy1 > 0 || dy2 > 0;
    bool connectsLeft = dx1 < 0 || dx2 < 0;
    bool connectsRight = dx1 > 0 || dx2 > 0;

    if (connectsDown && connectsLeft)
        return "body_down_left.png";

    if (connectsLeft && connectsUp)
        return "body_left_up.png";

    if (connectsRight && connectsDown)
        return "body_right_down.png";

    if (connectsUp && connectsRight)
        return "body_up_right.png";

    return "body_horizontal.png";
}

QVariantMap GameController::makeSnakeSegment(int index) const
{
    QString sprite;

    if (index == 0)
        sprite = headSprite();
    else if (index == m_snake.size() - 1)
        sprite = tailSprite();
    else
        sprite = bodySprite(index);

    QPoint point = m_snake.at(index);

    return {
        { "x", point.x() },
        { "y", point.y() },
        { "sprite", sprite }
    };
}