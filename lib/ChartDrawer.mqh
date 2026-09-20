//###<Experts/My/StatPulse/StatPulse.mq5>

#include "Logger.mqh"
#include "UUID.mqh"

namespace StatPulse {

class ChartDrawer {

public:
    static string DrawSymbol(datetime x, double y, int symbolCode, color vColor, ENUM_ARROW_ANCHOR anchor) {
        string objId = UUID::randomUuid();

        if (!ObjectCreate(0, objId, OBJ_ARROW, 0, x, y)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_ARROWCODE, symbolCode)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_COLOR, vColor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_ANCHOR, anchor)) {
            PrintLastError();
            return "";
        }

        ChartRedraw();
        return objId;
    }

    static string DrawLine(datetime x1, double y1, datetime x2, double y2, color vColor, int width) {
        return DrawLine(x1, y1, x2, y2, vColor, width, STYLE_SOLID, false, false);
    }

    static string DrawLine(
        datetime x1,
        double y1,
        datetime x2,
        double y2,
        color vColor,
        int width,
        ENUM_LINE_STYLE style,
        bool onTheBackOrder,
        bool rayRight
    ) {
        string objId = UUID::randomUuid();

        if (!ObjectCreate(0, objId, OBJ_TREND, 0, x1, y1, x2, y2)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_COLOR, vColor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_WIDTH, width)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_STYLE, style)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_BACK, onTheBackOrder)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_RAY_RIGHT, rayRight)) {
            PrintLastError();
            return "";
        }

        ChartRedraw();
        return objId;
    }

    static string DrawText(datetime x, double y, string value, color vColor, ENUM_ANCHOR_POINT anchor) {
        string objId = UUID::randomUuid();

        if (!ObjectCreate(0, objId, OBJ_TEXT, 0, x, y)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetString(0, objId, OBJPROP_TEXT, value)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_COLOR, vColor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_ANCHOR, anchor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetString(0, objId, OBJPROP_FONT, "Calibri")) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_FONTSIZE, 8)) {
            PrintLastError();
            return "";
        }

        ChartRedraw();
        return objId;
    }

    static string DrawRect(
        datetime x1,
        double y1,
        datetime x2,
        double y2,
        color vColor,
        int width,
        ENUM_LINE_STYLE style,
        bool onTheBackOrder,
        bool vFill
    ) {
        string objId = UUID::randomUuid();

        if (!ObjectCreate(0, objId, OBJ_RECTANGLE, 0, x1, y1, x2, y2)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_COLOR, vColor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_WIDTH, width)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_STYLE, style)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_FILL, vFill)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_BACK, onTheBackOrder)) {
            PrintLastError();
            return "";
        }

        ChartRedraw();
        return objId;
    }

    static string DrawLeftPriceLabel(datetime x, double y, color vColor, int width, bool onTheBackOrder) {
        string objId = UUID::randomUuid();

        if (!ObjectCreate(0, objId, OBJ_ARROW_LEFT_PRICE, 0, x, y)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_COLOR, vColor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_WIDTH, width)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_BACK, onTheBackOrder)) {
            PrintLastError();
            return "";
        }

        ChartRedraw();
        return objId;
    }

    static string DrawRightPriceLabel(datetime x, double y, color vColor, int width, bool onTheBackOrder) {
        string objId = UUID::randomUuid();

        if (!ObjectCreate(0, objId, OBJ_ARROW_RIGHT_PRICE, 0, x, y)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_COLOR, vColor)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_WIDTH, width)) {
            PrintLastError();
            return "";
        }

        if (!ObjectSetInteger(0, objId, OBJPROP_BACK, onTheBackOrder)) {
            PrintLastError();
            return "";
        }

        ChartRedraw();
        return objId;
    }
};

}