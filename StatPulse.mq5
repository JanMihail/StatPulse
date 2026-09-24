#property copyright "StatPulse"
#property version "1.0"

#include "MotionStatUi.mqh"
#include "MotionTracker.mqh"
#include "MqlUtils.mqh"
#include "TradeStrategy.mqh"
#include "lib/Logger.mqh"

//================== INPUTS ==========================================
enum Switch {
    SWITCH_ON, // ✔️ On
    SWITCH_OFF // ❌ Off
};

enum PctCalcMode {
    PCT_CALC_MODE_ALL,           // Все движения
    PCT_CALC_MODE_SAME_DIRECTION // По направлению
};

input group "⏰ Таймфрейм 1 (старший)";
input ENUM_TIMEFRAMES TIMEFRAME_1 = PERIOD_D1; // Таймфрейм
input int ATR_PERIOD_1 = 14;                   // Период ATR
input double KOEF_ATR_1 = 1.5;                 // Коэффициент коррекции ATR [1.5..2.0]
input int WINDOW_SIZE_1 = 200;                 // Размер исторического окна

input group "⏰ Таймфрейм 2 (средний)";
input ENUM_TIMEFRAMES TIMEFRAME_2 = PERIOD_H1; // Таймфрейм
input int ATR_PERIOD_2 = 14;                   // Период ATR
input double KOEF_ATR_2 = 1.5;                 // Коэффициент коррекции ATR [1.5..2.0]
input int WINDOW_SIZE_2 = 300;                 // Размер исторического окна

input group "⏰ Таймфрейм 3 (младший)";
input ENUM_TIMEFRAMES TIMEFRAME_3 = PERIOD_M15; // Таймфрейм
input int ATR_PERIOD_3 = 14;                    // Период ATR
input double KOEF_ATR_3 = 1.2;                  // Коэффициент коррекции ATR [1.2..1.5]
input int WINDOW_SIZE_3 = 500;                  // Размер исторического окна

input group "📈 Расчёты";
input PctCalcMode PCT_CALC_MODE = PCT_CALC_MODE_SAME_DIRECTION; // Режим расчёта перцентилей

input group "📈 Визуализация";
input Switch UI_DRAW_MOTION_ENABLED = SWITCH_ON; // Отрисовка движений
input Switch UI_STAT_PANEL_ENABLED = SWITCH_ON;  // Панель со статистикой
input color COLOR_TIMEFRAME_1 = clrRed;          // Цвет Таймфрейм 1 (старший)
input color COLOR_TIMEFRAME_2 = clrGreen;        // Цвет Таймфрейм 2 (средний)
input color COLOR_TIMEFRAME_3 = clrWhite;        // Цвет Таймфрейм 3 (младший)

namespace StatPulse {

//================== GLOBAL VARS ==========================================

bool warmUp = false; // Выполнен ли прогрев истории перед началом торговли
MotionTracker motionTracker1;
MotionTracker motionTracker2;
MotionTracker motionTracker3;
MotionStatUi motionStatUi;
TradeStrategy tradeStrategy;

int OnInit() {
    Logger::Info("Инициализация бинов...");

    bool isOk = true;
    isOk = isOk && motionTracker1.Init(&motionStatUi, TIMEFRAME_1, ATR_PERIOD_1, KOEF_ATR_1, WINDOW_SIZE_1);
    isOk = isOk && motionTracker2.Init(&motionStatUi, TIMEFRAME_2, ATR_PERIOD_2, KOEF_ATR_2, WINDOW_SIZE_2);
    isOk = isOk && motionTracker3.Init(&motionStatUi, TIMEFRAME_3, ATR_PERIOD_3, KOEF_ATR_3, WINDOW_SIZE_3);
    isOk = isOk && motionStatUi.Init();
    isOk = isOk && tradeStrategy.Init(&motionTracker1, &motionTracker2, &motionTracker3);

    if (!isOk) {
        return INIT_FAILED;
    }

    Logger::Info("Инициализаци бинов успешно завершена!");

    // Прогрев истории
    warmUp = false;
    if (IsRealMode()) {
        Logger::Info("Ожидание запуска прогрева истории...");
        EventSetTimer(1);
    } else {
        Logger::Info("Ожидание первого тика для начала прогрева истории...");
    }
    return (INIT_SUCCEEDED);
}

void OnTimer() {
    WarmUp();
    EventKillTimer();
}

void OnDeinit(const int reasonCode) {
    ObjectsDeleteAll(0);
    Logger::Info(StringFormat(
        "Советник остановлен! ReasonCode: %d, ReasonText: %s",
        reasonCode,
        GetReasonCodeMessage(reasonCode)
    ));
}

void OnTick() {
    if (!warmUp && IsTestingMode()) {
        WarmUp();
        return;
    }

    motionTracker1.OnTick();
    motionTracker2.OnTick();
    motionTracker3.OnTick();
    tradeStrategy.OnTick();
}

// Запуск прогрева необходимо запускать за пределами OnInit,
// т.к. из-за "особенности работы MT5" в OnInit ещё не готовы индикаторы и бары
void WarmUp() {
    Logger::Info("Прогрев истории перед началом торговли...");

    bool isOk = true;
    isOk = isOk && motionTracker1.WarmUp();
    isOk = isOk && motionTracker2.WarmUp();
    isOk = isOk && motionTracker3.WarmUp();

    if (isOk) {
        warmUp = true;
        Logger::Info("Прогрев истории успешно завершён!");
        Logger::Info("Советник успешно запущен!");
    } else {
        Logger::Error("Не удалось инициализировать советник");
        ExpertRemove();
    }
}

}