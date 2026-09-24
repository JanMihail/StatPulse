//###<Experts/My/StatPulse/StatPulse.mq5>

#include "ATR.mqh"
#include "MotionBuffer.mqh"
#include "MotionDrawer.mqh"
#include "MotionStatUi.mqh"
#include "lib/Logger.mqh"

namespace StatPulse {

class MotionTracker {

private:
    ENUM_TIMEFRAMES timeframe;        // Таймфрейм
    double koefAtr;                   // Коэффициент коррекции ATR
    ATR *const atr;                   // Индикатор ATR
    MotionBuffer *const motionBuffer; // Буфер завершённых движений FIFO
    MotionDrawer *const motionDrawer; // Рисовальщик движений
    MotionStatUi *motionStatUi;       // Графическая панель со статистикой движений
    Motion *currentMotion;            // Текущее незавершённое движение
    double currentMotionPct;          // Перцентиля текущего движения

public:
    MotionTracker()
        : atr(new ATR()),
          motionBuffer(new MotionBuffer()),
          motionDrawer(new MotionDrawer()),
          currentMotion(NULL),
          currentMotionPct(0.0) {}

    bool Init(
        MotionStatUi *pMotionStatUi,
        const ENUM_TIMEFRAMES pTimeframe,
        const int pAtrPeriod,
        const double pKoefAtr,
        const int pWindowSize
    ) {
        timeframe = pTimeframe;
        koefAtr = pKoefAtr;
        motionStatUi = pMotionStatUi;

        bool isOk = true;
        isOk = isOk && atr.Init(pTimeframe, pAtrPeriod);
        isOk = isOk && motionBuffer.Init(pWindowSize);
        isOk = isOk && motionDrawer.Init(pTimeframe, pWindowSize);

        return isOk;
    }

    ~MotionTracker() {
        delete atr;
        delete motionBuffer;
        delete motionDrawer;
        delete currentMotion;
    }

    /**
     * Прогрев истории
     */
    bool WarmUp(int deepBarsCount = 100000) {

        // Получаем исторические данные баров
        MqlRates bars[];
        ArraySetAsSeries(bars, true);
        int countBars = CopyRates(_Symbol, timeframe, 0, deepBarsCount, bars);

        if (countBars < 0) {
            PrintLastErrorWithArgs(StringFormat(
                "timeframe: %s, deepBarsCount: %d, countBars: %d",
                EnumToString(timeframe),
                deepBarsCount,
                countBars
            ));
            return false;
        }

        // Получаем исторические данные индикатора ATR
        double atrBuffer[];
        int countAtrs = atr.CopyBuffer(0, deepBarsCount, atrBuffer);

        if (countAtrs < 0) {
            PrintLastErrorWithArgs(StringFormat(
                "timeframe: %s, deepBarsCount: %d, countAtrs: %d",
                EnumToString(timeframe),
                deepBarsCount,
                countAtrs
            ));
            return false;
        }

        Logger::Info(StringFormat(
            "Бары и индикаторы загружены! Timeframe: %s. DeepBarsCount: %d. CountBars: %d. CountAtrs: %d",
            EnumToString(timeframe),
            deepBarsCount,
            countBars,
            countAtrs
        ));

        // Прогон от старых баров к новым (хронологический порядок)
        for (int i = countBars - 1; i >= 1; --i) {

            // Определяем high и low бара на M1
            MqlRates highestBarM1;
            MqlRates lowestBarM1;
            if (!Point::GetHighestAndLowestBar(timeframe, bars[i], highestBarM1, lowestBarM1)) {
                return false;
            }

            // Определем, что было раньше high или low
            bool lowFirst = (lowestBarM1.time < highestBarM1.time) ||
                            (lowestBarM1.time == highestBarM1.time && lowestBarM1.open < lowestBarM1.close);

            // Генерируем два тика в хронологической последовательности
            if (lowFirst) {
                OnNewTick(Point(lowestBarM1.time, lowestBarM1.low), atrBuffer[i]);
                OnNewTick(Point(highestBarM1.time, highestBarM1.high), atrBuffer[i]);
            } else {
                OnNewTick(Point(highestBarM1.time, highestBarM1.high), atrBuffer[i]);
                OnNewTick(Point(lowestBarM1.time, lowestBarM1.low), atrBuffer[i]);
            }
        }

        Logger::Info(StringFormat(
            "Буфер заполнен! TimeFrame: %s. Размер буфера: %d из %d",
            EnumToString(timeframe),
            motionBuffer.Count(),
            motionBuffer.MaxSize()
        ));

        return true;
    }

    void OnTick() {
        MqlTick lastTick;

        if (!SymbolInfoTick(_Symbol, lastTick)) {
            PrintLastError();
            Logger::Warn("Не удалось получить тик");
            return;
        }

        OnNewTick(Point(lastTick.time, lastTick.bid), atr.GetValue(0));

        // Обновляем перцентилю текущего движения
        currentMotionPct = PCT_CALC_MODE == PCT_CALC_MODE_ALL
                               ? motionBuffer.CalculatePercentile(currentMotion)
                               : motionBuffer.CalculatePercentileSameDirection(currentMotion);

        // Отрисовываем текущее движение
        motionDrawer.Draw(currentMotion);

        // Обновляем данные в панели со статистикой
        motionStatUi.UpdateLabels(timeframe, currentMotion.GetDirectionString(), currentMotionPct);
    }

    Motion *GetCurrentMotion() const {
        return currentMotion;
    }

    double GetCurrentMotionPct() const {
        return currentMotionPct;
    }

private:
    void OnNewTick(const Point &tickPoint, const double atrValue) {

        // Если движения нет - это первая итерация, инициализируем его
        if (currentMotion == NULL) {
            currentMotion = new Motion(timeframe, koefAtr, tickPoint, tickPoint, atrValue);
            return;
        }

        // Обрабатываем тик
        currentMotion.OnNewTick(tickPoint, atrValue);

        // Если движение завершено
        if (currentMotion.GetStatus() == MOTION_STATUS_DONE) {

            // Отрисовываем движение
            motionDrawer.Draw(currentMotion);

            // Добавляем его в буфер
            motionBuffer.Add(currentMotion);

            // Создаём следующее на основе текущего
            Motion *nextMotion = new Motion(timeframe, koefAtr, currentMotion.GetExtremum(), tickPoint, atrValue);
            delete currentMotion;
            currentMotion = nextMotion;
        }
    }
};

}