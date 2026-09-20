//###<Experts/My/StatPulse/StatPulse.mq5>

namespace StatPulse {

string GetReasonCodeMessage(int reasonCode) {
    switch (reasonCode) {
        case REASON_PROGRAM:      return "Программа завершена через ExpertRemove()";
        case REASON_REMOVE:       return "Программа удалена с графика";
        case REASON_RECOMPILE:    return "Исходный код перекомпилирован";
        case REASON_CHARTCHANGE:  return "Изменен символ или таймфрейм графика";
        case REASON_CHARTCLOSE:   return "График закрыт";
        case REASON_PARAMETERS:   return "Изменены входные параметры (Inputs)";
        case REASON_ACCOUNT:      return "Сменен торговый счет";
        case REASON_TEMPLATE:     return "Применен новый шаблон графика";
        case REASON_INITFAILED:   return "Ошибка в функции OnInit()";
        case REASON_CLOSE:        return "Торговый терминал закрыт";
        default:                  return "Неизвестная причина деинициализации";
    }
}

string TimeframeToShortString(ENUM_TIMEFRAMES timeframe) {
    switch (timeframe) {
        case PERIOD_CURRENT: return "CURRENT";
        case PERIOD_M1:      return "M1";
        case PERIOD_M2:      return "M2";
        case PERIOD_M3:      return "M3";
        case PERIOD_M4:      return "M4";
        case PERIOD_M5:      return "M5";
        case PERIOD_M6:      return "M6";
        case PERIOD_M10:     return "M10";
        case PERIOD_M12:     return "M12";
        case PERIOD_M15:     return "M15";
        case PERIOD_M20:     return "M20";
        case PERIOD_M30:     return "M30";
        case PERIOD_H1:      return "H1";
        case PERIOD_H2:      return "H2";
        case PERIOD_H3:      return "H3";
        case PERIOD_H4:      return "H4";
        case PERIOD_H6:      return "H6";
        case PERIOD_H8:      return "H8";
        case PERIOD_H12:     return "H12";
        case PERIOD_D1:      return "D1";
        case PERIOD_W1:      return "W1";
        case PERIOD_MN1:     return "MN1";
        default:             return "UNKNOWN";
    }
}

string BarToString(const MqlRates &bar) {
    return StringFormat(
        "Bar(Time: %s, O: %G, H: %G: L: %G, C: %G)",
        TimeToString(bar.time),
        bar.open,
        bar.high,
        bar.low,
        bar.close
    );
}

bool IsTestingMode() {
    return MQLInfoInteger(MQL_TESTER) == 1;
}

bool IsRealMode() {
    return MQLInfoInteger(MQL_TESTER) == 0;
}

}