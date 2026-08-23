//###<Experts/My/StatPulse/StatPulse.mq5>

#include "ATR.mqh"

namespace StatPulse {

class MotionTracker {

private:
    ATR atr;
    ENUM_TIMEFRAMES timeframe;
    double koefAtr;
    int windowSize;

public:
    bool Init(const ENUM_TIMEFRAMES pTimeframe, const int pAtrPeriod, const double pKoefAtr, const int pWindowSize) {
        timeframe = pTimeframe;
        koefAtr = pKoefAtr;
        windowSize = pWindowSize;
        return atr.Init(pTimeframe, pAtrPeriod);
    }

    /**
     * Прогрев истории
     */
    bool WarmUp() {
        return true;
    }

    void OnTick() {}
};

}