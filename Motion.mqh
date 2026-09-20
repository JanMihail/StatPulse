//###<Experts/My/StatPulse/StatPulse.mq5>

#include "Point.mqh"
#include "lib/Logger.mqh"
#include "lib/UUID.mqh"

namespace StatPulse {

enum MotionDirection {
    MOTION_DIRECTION_UP,  // Вверх
    MOTION_DIRECTION_DOWN // Вниз
};

enum MotionStatus {
    MOTION_STATUS_IN_PROGRESS, // Движение формируется
    MOTION_STATUS_DONE         // Движение завершено
};

class Motion {

private:
    const string id;                 // Идентификатор движения
    const ENUM_TIMEFRAMES timeframe; // Таймфрейм
    const double koefAtr;            // Коэффициент коррекции ATR
    MotionDirection direction;       // Направление движения
    MotionStatus status;             // Статус движения
    Point *start;                    // Точка начала движения
    Point *extremum;                 // Экстремум движения
    double sumAtr;                   // Инкрементальная сумма ATR
    ulong ticksCount;                // Инкрементальное количество тиков движения
    double lengthOnDone;             // Длина движения, если оно уже завершено (чтобы не вычислять)

public:
    Motion(
        const ENUM_TIMEFRAMES pTimeframe,
        const double pKoefAtr,
        const Point &pStart,
        const Point &pExtremum,
        const double atrValue
    )
        : id(UUID::randomUuid()),
          timeframe(pTimeframe),
          koefAtr(pKoefAtr),
          direction(pStart.GetPrice() < pExtremum.GetPrice() ? MOTION_DIRECTION_UP : MOTION_DIRECTION_DOWN),
          status(MOTION_STATUS_IN_PROGRESS),
          start(new Point(pStart)),
          extremum(new Point(pExtremum)),
          sumAtr(atrValue),
          ticksCount(1),
          lengthOnDone(0) {}

    Motion(const Motion &motion)
        : id(motion.id),
          timeframe(motion.timeframe),
          koefAtr(motion.koefAtr),
          direction(motion.direction),
          status(motion.status),
          start(new Point(motion.start)),
          extremum(new Point(motion.extremum)),
          sumAtr(motion.sumAtr),
          ticksCount(motion.ticksCount),
          lengthOnDone(motion.lengthOnDone) {}

    ~Motion() {
        delete start;
        delete extremum;
    }

    void OnNewTick(const Point &tickPoint, const double atrValue) {
        if (status == MOTION_STATUS_DONE) {
            Logger::Error(StringFormat(
                "Завершённые движения не должны сюда попадать. this: %s, tickPoint: %s, atrValue: %G",
                ToString(),
                tickPoint.ToString(),
                atrValue
            ));
            ExpertRemove();
        }

        ticksCount++;
        sumAtr += atrValue;

        // Если движение восходящее
        if (direction == MOTION_DIRECTION_UP) {

            // Если новый тик выше экстремума, обновляем экстремум
            if (tickPoint.GetPrice() > extremum.GetPrice()) {
                delete extremum;
                extremum = new Point(tickPoint);
            }

            else {
                // Вычисляем размер коррекции
                double correction = extremum.GetPrice() - tickPoint.GetPrice();

                // Если коррекция превысила допустимый порог ATR, завершаем движение
                if (correction >= koefAtr * atrValue) {
                    status = MOTION_STATUS_DONE;
                    lengthOnDone = CalcLength();
                }
            }
        }

        // Если движение нисходящее
        else if (direction == MOTION_DIRECTION_DOWN) {

            // Если новый тик ниже экстремума, обновляем экстремум
            if (tickPoint.GetPrice() < extremum.GetPrice()) {
                delete extremum;
                extremum = new Point(tickPoint);
            }

            else {
                // Вычисляем размер коррекции
                double correction = tickPoint.GetPrice() - extremum.GetPrice();

                // Если коррекция превысила допустимый порог ATR, завершаем движение
                if (correction >= koefAtr * atrValue) {
                    status = MOTION_STATUS_DONE;
                    lengthOnDone = CalcLength();
                }
            }
        }

        else {
            Logger::Error(StringFormat("Неизвестное направление движения. this: %s", ToString()));
            ExpertRemove();
        }
    }

    string GetId() const {
        return id;
    }

    ENUM_TIMEFRAMES GetTimeframe() const {
        return timeframe;
    }

    MotionDirection GetDirection() const {
        return direction;
    }

    string GetDirectionString() const {
        if (direction == MOTION_DIRECTION_UP) {
            return "UP";
        }

        if (direction == MOTION_DIRECTION_DOWN) {
            return "DOWN";
        }

        return "UNKNOWN";
    }

    MotionStatus GetStatus() const {
        return status;
    }

    double GetLength() const {
        if (status == MOTION_STATUS_DONE) {
            return lengthOnDone;
        }

        return CalcLength();
    }

    Point *const GetStart() const {
        return start;
    }

    Point *const GetExtremum() const {
        return extremum;
    }

    string ToString() const {
        return StringFormat(
            "Motion(id: %s, timeframe: %s, direction: %s, status: %s, start: %s, extremum: %s, sumAtr: %G, ticksCount: "
            "%d)",
            id,
            EnumToString(timeframe),
            EnumToString(direction),
            EnumToString(status),
            start.ToString(),
            extremum.ToString(),
            sumAtr,
            ticksCount
        );
    }

private:
    double CalcLength() const {
        double meanAtr = sumAtr / ticksCount;
        return MathAbs(extremum.GetPrice() - start.GetPrice()) / meanAtr;
    }
};

}