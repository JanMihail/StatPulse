//###<Experts/My/StatPulse/StatPulse.mq5>

#include "MqlUtils.mqh"

namespace StatPulse {

class MotionStatUi {

private:
    string objPrefix;

public:
    MotionStatUi() : objPrefix("MOTION_STAT") {}

    bool Init() {
        ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, 0x241915);
        ChartSetInteger(0, CHART_COLOR_CHART_UP, 0x677c05);
        ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, 0x241915);
        ChartSetInteger(0, CHART_COLOR_CHART_DOWN, 0x3f33d2);
        ChartSetInteger(0, CHART_COLOR_CHART_LINE, 0xffffff);
        ChartSetInteger(0, CHART_COLOR_BACKGROUND, 0x241915);
        ChartSetInteger(0, CHART_COLOR_FOREGROUND, 0xffffff);
        ChartSetInteger(0, CHART_SHOW_GRID, false);
        ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
        ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
        ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
        ChartSetInteger(0, CHART_SHOW_VOLUMES, false);
        ChartSetInteger(0, CHART_SCALE, 3);
        ChartSetInteger(0, CHART_SHIFT, true);

        if (UI_STAT_PANEL_ENABLED == SWITCH_ON) {
            ObjectsDeleteAll(0, objPrefix);
            CreateTable();
            ChartRedraw();
        }

        return true;
    }

    ~MotionStatUi() {
        ObjectsDeleteAll(0, objPrefix);
    }

    void UpdateLabels(ENUM_TIMEFRAMES timeframe, string direction, double pct) {
        if (UI_STAT_PANEL_ENABLED == SWITCH_OFF) {
            return;
        }

        string labelDir = timeframe == TIMEFRAME_1 ? "TF1_DIR" : timeframe == TIMEFRAME_2 ? "TF2_DIR" : "TF3_DIR";
        string labelPct = timeframe == TIMEFRAME_1 ? "TF1_PCT" : timeframe == TIMEFRAME_2 ? "TF2_PCT" : "TF3_PCT";

        color vColor = pct >= 90 ? clrGreen : clrBlack;
        string fontName = pct >= 90 ? "Consolas Bold" : "Consolas";

        // Направление
        string labelName = StringFormat("%s_TEXT_%s", objPrefix, labelDir);
        ObjectSetString(0, labelName, OBJPROP_TEXT, direction);
        ObjectSetInteger(0, labelName, OBJPROP_COLOR, vColor);
        ObjectSetString(0, labelName, OBJPROP_FONT, fontName);

        // Перцентиль
        labelName = StringFormat("%s_TEXT_%s", objPrefix, labelPct);

        ObjectSetString(0, labelName, OBJPROP_TEXT, StringFormat("%.1f%%", pct));
        ObjectSetInteger(0, labelName, OBJPROP_COLOR, vColor);
        ObjectSetString(0, labelName, OBJPROP_FONT, fontName);
    }

private:
    void CreateTable() {
        int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

        int rowHeight = 30;                             // Высота строки
        int colWidths[] = {85, 50, 70, 50, 70, 50, 70}; // Ширина колонок: [Пустая, Pct, $, %]

        int tableWidth = 0;
        for (int i = 0; i < ArraySize(colWidths); ++i)
            tableWidth += colWidths[i];

        int startX = chartWidth - tableWidth - 40; // Отступ слева
        int startY = 10;                           // Отступ сверху
        int rowCount = 3;                          // Количество строк
        int colCount = 7;                          // Количество столбцов
        int borderWidth = 1;                       // Толщина границ ячейки
        int cellMap[3][7] = {
            // Разметка ячеек. 0 - не рисовать. 1 - рисовать
            {0, 1, 1, 1, 1, 1, 1},
            {0, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1}
        };

        // 1. Создание ячеек
        int currentY = startY;
        for (int row = 0; row < rowCount; ++row) {
            int currentX = startX;

            for (int col = 0; col < colCount; ++col) {
                string objName = StringFormat("%s_cell_%d_%d", objPrefix, row, col);

                if (cellMap[row][col] == 0) {
                    // не рисуем эти ячейки
                }

                // Объединённые ячейки в заголовке
                else if (row == 0) {
                    if (col == 1 || col == 3 || col == 5) {
                        CreateCell(
                            objName,
                            currentX,
                            currentY,
                            colWidths[col] + colWidths[col + 1] + borderWidth,
                            rowHeight + borderWidth,
                            borderWidth
                        );
                    }
                }

                else {
                    CreateCell(objName, currentX, currentY, colWidths[col] + borderWidth, rowHeight + borderWidth, borderWidth);
                }

                currentX += colWidths[col];
            }

            currentY += rowHeight;
        }

        // 2. Создание объектов с текстом
        string textObjectNames[3][7] = {
            {"", "", "HEAD_TF1", "", "HEAD_TF2", "", "HEAD_TF3"},
            {"", "HEAD_TF1_DIR", "HEAD_TF1_PCT", "HEAD_TF2_DIR", "HEAD_TF2_PCT", "HEAD_TF3_DIR", "HEAD_TF3_PCT"},
            {"SYMBOL_NAME", "TF1_DIR", "TF1_PCT", "TF2_DIR", "TF2_PCT", "TF3_DIR", "TF3_PCT"}
        };

        string textValues[3][7] = {
            {"", "", TimeframeToShortString(TIMEFRAME_1), "", TimeframeToShortString(TIMEFRAME_2), "", TimeframeToShortString(TIMEFRAME_3)},
            {"", "Dir", "Pct", "Dir", "Pct", "Dir", "Pct"},
            {_Symbol, "NONE", "0%", "NONE", "0%", "NONE", "0%"}
        };

        int fontSize = 10;

        currentY = startY;
        for (int r = 0; r < rowCount; r++) {
            int currentX = startX;
            for (int c = 0; c < colCount; c++) {
                string text = textValues[r][c];

                if (StringLen(text) == 0) {
                    currentX += colWidths[c];
                    continue;
                }

                string labelName = StringFormat("%s_TEXT_%s", objPrefix, textObjectNames[r][c]);

                if (ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0)) {
                    bool isHeader = (r < 2);
                    bool isFirstCol = (c == 0);

                    string fontName = (isHeader || isFirstCol) ? "Consolas Bold" : "Consolas";

                    ObjectSetString(0, labelName, OBJPROP_FONT, fontName);
                    ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, fontSize);
                    ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrBlack);
                    ObjectSetString(0, labelName, OBJPROP_TEXT, text);
                    ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);

                    int textY = currentY + (rowHeight / 2); // Центрирование по вертикали

                    if (isFirstCol) {
                        // Выравнивание ПО ЛЕВОМУ краю (с небольшим отступом в 5px)
                        ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT);
                        ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, currentX + 5);
                        ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, textY);
                    } else {
                        // Выравнивание ПО ПРАВОМУ краю (с отступом 10px от правой границы ячейки)
                        ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_RIGHT);
                        ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, currentX + colWidths[c] - 5);
                        ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, textY);
                    }
                }

                currentX += colWidths[c];
            }
            currentY += rowHeight;
        }
    }

    void CreateCell(string objName, int x, int y, int width, int height, int borderWidth) {
        if (ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0)) {
            ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
            ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
            ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
            ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);

            // Настройка границ и фона
            ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrWhite);
            ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, borderWidth);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, clrBlack);
            ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        }
    }
};

}