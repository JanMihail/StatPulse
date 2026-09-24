//###<Experts/My/StatPulse/StatPulse.mq5>

#include "Motion.mqh"
#include <Trade/Trade.mqh>

namespace StatPulse {

class TradeStrategy {

private:
    MotionTracker *motionTracker1;
    MotionTracker *motionTracker2;
    MotionTracker *motionTracker3;
    CTrade trade;
    MotionDirection motionDirection;
    double lengthToClose;
    double lot;
    double lotMultiplier;

public:
    bool Init(MotionTracker *pMotionTracker1, MotionTracker *pMotionTracker2, MotionTracker *pMotionTracker3) {
        motionTracker1 = pMotionTracker1;
        motionTracker2 = pMotionTracker2;
        motionTracker3 = pMotionTracker3;
        lot = 0.01;
        lotMultiplier = 2;

        if (!trade.SetTypeFillingBySymbol(_Symbol)) {
            PrintLastError();
            return false;
        }

        return true;
    }

    void OnTick() {
        if (PositionsTotal() == 0) {
            ManageIn();
        } else {
            ManageOut();
        }
    }

private:
    void ManageIn() {
        Motion *m1 = motionTracker1.GetCurrentMotion();
        double pct1 = motionTracker1.GetCurrentMotionPct();

        Motion *m2 = motionTracker2.GetCurrentMotion();
        double pct2 = motionTracker2.GetCurrentMotionPct();

        Motion *m3 = motionTracker3.GetCurrentMotion();
        double pct3 = motionTracker3.GetCurrentMotionPct();

        if (pct1 >= 5 && pct1 <= 20) {

            // double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            // double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

            // lengthToClose = m1.GetLength() + m1.GetLength() * 0.5;
            motionDirection = m1.GetDirection();

            // RecalcLot();
            if (m1.GetDirection() == MOTION_DIRECTION_UP) {

                trade.Buy(lot, _Symbol);

            } else if (m1.GetDirection() == MOTION_DIRECTION_DOWN) {

                trade.Sell(lot, _Symbol);
            }
        }
    }

    void ManageOut() {
        Motion *m1 = motionTracker1.GetCurrentMotion();
        double pct1 = motionTracker1.GetCurrentMotionPct();

        if (motionDirection != m1.GetDirection() || pct1 >= 50.0) {
            CloseAllPositions();
        }
    }

private:
    ENUM_POSITION_TYPE GetCurrentPositionType() const {
        ulong ticket = PositionGetTicket(0);
        return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    }

    void CloseAllPositions() {
        int n = PositionsTotal();

        ulong tickets[];
        ArrayResize(tickets, n);

        for (int i = 0; i < n; i++) {
            ulong ticket = PositionGetTicket(i);
            tickets[i] = ticket;
        }

        for (int i = 0; i < n; i++) {
            trade.PositionClose(tickets[i]);
        }

        ArrayFree(tickets);
    }

    void RecalcLot() {
        if (isLastDealProfit()) {
            lot = 0.01;
        }

        double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
        lot = MathFloor(lot * lotMultiplier / lotStep) * lotStep;
    }

    bool isLastDealProfit() {
        HistorySelect(0, TimeCurrent());
        int n = HistoryDealsTotal();

        if (n <= 1) {
            return true;
        }

        for (int i = n - 1; i > 0; i--) {
            ulong dealTicket = HistoryDealGetTicket(i);
            long entry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

            if (entry != ENUM_DEAL_ENTRY::DEAL_ENTRY_OUT) {
                continue;
            }

            double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            PrintFormat("n = %G, dealTicket = %G, profit = %G", n, dealTicket, profit);

            return profit >= 0;
        }

        return true;
    }
};
}