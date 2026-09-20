//###<Experts/My/StatPulse/StatPulse.mq5>

#include "lib/Logger.mqh"

namespace StatPulse {

class Point {

private:
    const datetime time;
    const double price;

public:
    Point(const datetime pTime, const double pPrice) : time(pTime), price(pPrice) {}
    Point(const Point &point) : time(point.time), price(point.price) {}

    datetime GetTime() const {
        return time;
    }

    double GetPrice() const {
        return price;
    }

    string ToString() const {
        return StringFormat("Point(time: %s, price: %G)", TimeToString(time), price);
    }

    static bool GetHighestAndLowestBar(
        const ENUM_TIMEFRAMES timeframe,
        const MqlRates &bar,
        MqlRates &highestBarM1,
        MqlRates &lowestBarM1
    ) {
        // Получаем бары M1 внутри bar
        MqlRates m1Bars[];
        if (CopyRates(_Symbol, PERIOD_M1, bar.time, bar.time + PeriodSeconds(timeframe) - 1, m1Bars) < 0) {
            PrintLastErrorWithArgs(StringFormat("timeframe: %s, bar: %s", EnumToString(timeframe), BarToString(bar)));
            return false;
        }

        int n = ArraySize(m1Bars);

        if (n == 0) {
            Logger::Error(StringFormat(
                "Не найдено ниодного M1 бара внутри bar. timeframe: %s. bar: %s",
                EnumToString(timeframe),
                BarToString(bar)
            ));
            return false;
        }

        // Вычисляем самый высокий и низкий бар M1 внутри bar
        int highestBarIdx = 0;
        int lowestBarIdx = 0;
        for (int i = 0; i < n; ++i) {
            if (m1Bars[i].high > m1Bars[highestBarIdx].high) {
                highestBarIdx = i;
            }

            if (m1Bars[i].low < m1Bars[lowestBarIdx].low) {
                lowestBarIdx = i;
            }
        }

        highestBarM1 = m1Bars[highestBarIdx];
        lowestBarM1 = m1Bars[lowestBarIdx];

        return true;
    }
};

}