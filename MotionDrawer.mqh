//###<Experts/My/StatPulse/StatPulse.mq5>

#include "Motion.mqh"
#include "lib/ChartDrawer.mqh"
#include "lib/Logger.mqh"
#include <Generic/ArrayList.mqh>
#include <Generic/LinkedList.mqh>

namespace StatPulse {

class MotionDrawer {

private:
    /**
     * Буфер движений на графике
     * Идут в хронологичном порядке. Список содержит объекты представляющие один Motion
     */
    CLinkedList<CArrayList<string> *> *motionBuffer;

    ENUM_TIMEFRAMES timeframe; // Таймфрейм
    int maxSize;               // Максимальное количество движений для вывода на экран
    color vColor;              // Цвет линий

    string lastMotionLineId;

public:
    MotionDrawer() : motionBuffer(new CLinkedList<CArrayList<string> *>()), lastMotionLineId("") {}

    bool Init(const ENUM_TIMEFRAMES pTimeframe, const int pMaxSize) {
        timeframe = pTimeframe;
        maxSize = pMaxSize;
        vColor = timeframe == TIMEFRAME_1   ? COLOR_TIMEFRAME_1
                 : timeframe == TIMEFRAME_2 ? COLOR_TIMEFRAME_2
                                            : COLOR_TIMEFRAME_3;
        return true;
    }

    ~MotionDrawer() {
        while (motionBuffer.Count() > 0) {
            motionBuffer.First().Value().Clear();
            delete motionBuffer.First().Value();
            motionBuffer.RemoveFirst();
        }
        delete motionBuffer;
    }

    void Draw(const Motion &motion) {
        if (UI_DRAW_MOTION_ENABLED == SWITCH_OFF) {
            return;
        }

        if (motion.GetStatus() == MOTION_STATUS_DONE) {
            if (!DropFirstItemIfBufferIsFull()) {
                return;
            }

            DrawMotion(motion);
        }

        else {
            DrawMotionInProgress(motion);
        }
    }

    string ToString() const {
        return StringFormat(
            "MotionDrawer(timeframe: %s, count: %d, maxSize: %d)",
            EnumToString(timeframe),
            motionBuffer.Count(),
            maxSize
        );
    }

private:
    bool DropFirstItemIfBufferIsFull() {
        // Если буфер заполнен, удаляем первый элемент
        if (motionBuffer.Count() == maxSize) {

            // Удаляем объекты на графике, которые относятся к первому элементу
            CArrayList<string> *innerList = motionBuffer.First().Value();
            for (int i = 0; i < innerList.Count(); ++i) {
                string chartObjectId;
                innerList.TryGetValue(i, chartObjectId);

                if (!ObjectDelete(0, chartObjectId)) {
                    PrintLastError();
                    return false;
                }
            }

            innerList.Clear();
            delete innerList;
            motionBuffer.RemoveFirst();
        }

        return true;
    }

    void DrawMotion(const Motion &motion) {
        string lineId = ChartDrawer::DrawLine(
            motion.GetStart().GetTime(),
            motion.GetStart().GetPrice(),
            motion.GetExtremum().GetTime(),
            motion.GetExtremum().GetPrice(),
            vColor,
            1,
            STYLE_SOLID,
            false,
            false
        );

        if (lineId == "") {
            return;
        }

        CArrayList<string> *motionChartObjects = new CArrayList<string>();
        motionChartObjects.Add(lineId);
        motionBuffer.Add(motionChartObjects);
    }

    void DrawMotionInProgress(const Motion &motion) {
        if (lastMotionLineId == "") {
            lastMotionLineId = ChartDrawer::DrawLine(
                motion.GetStart().GetTime(),
                motion.GetStart().GetPrice(),
                motion.GetExtremum().GetTime(),
                motion.GetExtremum().GetPrice(),
                vColor,
                1,
                STYLE_DOT,
                false,
                false
            );
            return;
        }

        if (!ObjectMove(0, lastMotionLineId, 0, motion.GetStart().GetTime(), motion.GetStart().GetPrice())) {
            PrintLastErrorWithArgs(StringFormat("lastMotionLineId: %s", lastMotionLineId));
            return;
        }

        if (!ObjectMove(0, lastMotionLineId, 1, motion.GetExtremum().GetTime(), motion.GetExtremum().GetPrice())) {
            PrintLastErrorWithArgs(StringFormat("lastMotionLineId: %s", lastMotionLineId));
            return;
        }
    }
};
}