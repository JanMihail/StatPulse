//###<Experts/My/StatPulse/StatPulse.mq5>

#include "Motion.mqh"
#include "MotionTreap.mqh"
#include <Generic/LinkedList.mqh>

namespace StatPulse {

class MotionBuffer {

private:
    int maxSize;                   // Максимальные размер буфера
    CLinkedList<Motion *> *buffer; // Буфер
    MotionTreap *treap;            // Декартово дерево со всеми движениями

    MotionTreap *treapUp;   // Декартово дерево с движениями UP
    MotionTreap *treapDown; // Декартово дерево с движениями DOWN

public:
    MotionBuffer()
        : buffer(new CLinkedList<Motion *>()),
          treap(new MotionTreap()),
          treapUp(new MotionTreap()),
          treapDown(new MotionTreap()) {}

    bool Init(const int pMaxSize) {
        maxSize = pMaxSize;
        return true;
    }

    ~MotionBuffer() {
        while (buffer.Count() > 0) {
            treap.Erase(buffer.First().Value());
            treapUp.Erase(buffer.First().Value());
            treapDown.Erase(buffer.First().Value());

            delete buffer.First().Value();
            buffer.RemoveFirst();
        }
        delete buffer;
        delete treap;
        delete treapUp;
        delete treapDown;
    }

    void Add(const Motion &motion) {
        if (buffer.Count() == maxSize) {
            Motion *firstMotion = buffer.First().Value();
            treap.Erase(firstMotion);

            if (firstMotion.GetDirection() == MOTION_DIRECTION_UP) {
                treapUp.Erase(firstMotion);
            } else if (firstMotion.GetDirection() == MOTION_DIRECTION_DOWN) {
                treapDown.Erase(firstMotion);
            }

            delete firstMotion;
            buffer.RemoveFirst();
        }

        Motion *newMotion = new Motion(motion);
        buffer.Add(newMotion);

        treap.Insert(newMotion);

        if (newMotion.GetDirection() == MOTION_DIRECTION_UP) {
            treapUp.Insert(newMotion);
        } else if (motion.GetDirection() == MOTION_DIRECTION_DOWN) {
            treapDown.Insert(newMotion);
        }
    }

    int Count() const {
        return buffer.Count();
    }

    int MaxSize() const {
        return maxSize;
    }

    bool IsFull() const {
        return buffer.Count() == maxSize;
    }

    double CalculatePercentile(const Motion &motion) const {
        return treap.GetPct(motion);
    }

    double CalculatePercentileSameDirection(const Motion &motion) const {
        if (motion.GetDirection() == MOTION_DIRECTION_UP) {
            return treapUp.GetPct(motion);
        } else {
            return treapDown.GetPct(motion);
        }
    }

    string ToString() const {
        return StringFormat(
            "MotionBuffer(count: %d, maxSize: %d, isFull: %s)",
            Count(),
            MaxSize(),
            IsFull() ? "true" : "false"
        );
    }
};

}