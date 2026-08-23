//###<Experts/My/StatPulse/StatPulse.mq5>

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
            PrintFormat("Ошибка инициализации iATR. timeframe=%s, period=%d", EnumToString(timeframe), period);
            return false;
        }

        ArraySetAsSeries(buffer, true);
        return true;
    }

    ~ATR() {
        if (handle != INVALID_HANDLE) {
            if (!IndicatorRelease(handle)) {
                Print("Ошибка освобождения дескриптора индикатора ATR");
            }
        }
    }

    /**
     * Нумерация идёт от текущей свечи в прошлое
     * 0 - текущая несформированная свеча
     * 1 - предыдущая сформированная свеча
     * и т.д.
     */
    double getValue(const int index) {
        if (CopyBuffer(handle, 0, index, 1, buffer) < 0) {
            PrintFormat("Ошибка при копировании буфера ATR. LastError = %d. index = %d", GetLastError(), index);
            return -1;
        }
        return buffer[0];
    }
};

}