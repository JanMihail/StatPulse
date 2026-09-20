//###<Experts/My/StatPulse/StatPulse.mq5>

#include "lib/Logger.mqh"

namespace StatPulse {

class ATR {

private:
    int handle;
    double buffer[];

public:
    ATR() : handle(INVALID_HANDLE) {}

    bool Init(const ENUM_TIMEFRAMES timeframe, const int period) {
        handle = iATR(_Symbol, timeframe, period);

        if (handle == INVALID_HANDLE) {
            PrintLastErrorWithArgs(StringFormat("timeframe: %s, period: %d", EnumToString(timeframe), period));
            return false;
        }

        ArraySetAsSeries(buffer, true);
        return true;
    }

    ~ATR() {
        IndicatorRelease(handle);
    }

    int CopyBuffer(int startPos, int count, double &bufferOut[]) {
        ArraySetAsSeries(bufferOut, true);
        int result = ::CopyBuffer(handle, 0, startPos, count, bufferOut);

        if (result < 0) {
            PrintLastErrorWithArgs(StringFormat("startPos: %d, count: %d", startPos, count));
        }

        return result;
    }

    /**
     * Нумерация идёт от текущей свечи в прошлое
     * 0 - текущая несформированная свеча
     * 1 - предыдущая сформированная свеча
     * и т.д.
     */
    double GetValue(const int index) {
        if (::CopyBuffer(handle, 0, index, 1, buffer) < 0) {
            PrintLastErrorWithArgs(StringFormat("index: %d", index));
            return 0.0;
        }
        return buffer[0];
    }
};

}