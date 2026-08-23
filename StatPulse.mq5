#property copyright "StatPulse"
#property version "1.0"

#include "ATR.mqh"
#include "MotionTracker.mqh"

//================== INPUTS ==========================================

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

namespace StatPulse {

//================== GLOBAL VARS ==========================================

MotionTracker motionTracker1;
MotionTracker motionTracker2;
MotionTracker motionTracker3;

int OnInit() {
    Print("Инициализация бинов...");

    if (motionTracker1.Init(TIMEFRAME_1, ATR_PERIOD_1, KOEF_ATR_1, WINDOW_SIZE_1) &&
        motionTracker2.Init(TIMEFRAME_2, ATR_PERIOD_2, KOEF_ATR_2, WINDOW_SIZE_2) &&
        motionTracker3.Init(TIMEFRAME_3, ATR_PERIOD_3, KOEF_ATR_3, WINDOW_SIZE_3)) {
        Print("OK!");
    } else {
        return INIT_FAILED;
    }

    Print("Прогрев истории перед началом торговли...");
    if (motionTracker1.WarmUp() && motionTracker2.WarmUp() && motionTracker3.WarmUp()) {
        Print("OK!");
    } else {
        return INIT_FAILED;
    }

    Print("Советник запущен!");
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    PrintFormat("Советник остановлен! Reason: %d", reason);
}

void OnTick() {
    motionTracker1.OnTick();
    motionTracker2.OnTick();
    motionTracker3.OnTick();
}

}