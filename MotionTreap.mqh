//###<Experts/My/StatPulse/StatPulse.mq5>

#include "Motion.mqh"

namespace StatPulse {

class MotionTreap {
    class Node {

    public:
        const Motion *const motion; // Ключ дерева motion.length
        const int priority;         // Приоритет
        int size;                   // Размер левого и праваго дерева + сам узел
        Node *left;                 // Левая ветка
        Node *right;                // Правая ветка

    public:
        Node(const Motion *pMotion) : motion(pMotion), priority(MathRand()), size(1), left(NULL), right(NULL) {}

        ~Node() {
            // delete left;
            // delete right;
        }

        static int GetSize(Node *node) {
            return node != NULL ? node.size : 0;
        }

        static void UpdateSize(Node *node) {
            if (node != NULL) {
                node.size = 1 + GetSize(node.left) + GetSize(node.right);
            }
        }

        static bool Less(const Motion &m1, const Motion &m2) {
            if (m1.GetLength() != m2.GetLength()) {
                return m1.GetLength() < m2.GetLength();
            }
            return m1.GetId() < m2.GetId();
        }

        static bool Equals(const Motion &m1, const Motion &m2) {
            return m1.GetId() == m2.GetId() && m1.GetLength() == m2.GetLength();
        }

        static void Merge(Node *&newRoot, Node *a, Node *b) {
            if (a == NULL || b == NULL) {
                newRoot = a == NULL ? b : a;
            }

            else if (a.priority > b.priority) {
                Merge(a.right, a.right, b);
                newRoot = a;
                UpdateSize(newRoot);
            }

            else {
                Merge(b.left, a, b.left);
                newRoot = b;
                UpdateSize(newRoot);
            }
        }

        static void Split(Node *n, const Motion &motion, Node *&a, Node *&b) {
            if (n == NULL) {
                a = NULL;
                b = NULL;
            }

            else if (Less(n.motion, motion)) {
                Split(n.right, motion, n.right, b);
                a = n;
                UpdateSize(a);
            }

            else {
                Split(n.left, motion, a, n.left);
                b = n;
                UpdateSize(b);
            }
        }
    };

private:
    MotionTreap::Node *root;

public:
    MotionTreap() : root(NULL) {}

    ~MotionTreap() {
        delete root;
    }

    int GetSize() const {
        return root == NULL ? 0 : root.size;
    }

    void Insert(const Motion *motion) {
        MotionTreap::Node *newNode = new MotionTreap::Node(motion);

        MotionTreap::Node *less = NULL;
        MotionTreap::Node *greater = NULL;
        MotionTreap::Node::Split(root, motion, less, greater);
        MotionTreap::Node::Merge(less, less, newNode);
        MotionTreap::Node::Merge(root, less, greater);
    }

    void Erase(const Motion &motion) {
        root = Erase(root, motion);
    }

    double GetPct(const Motion &motion) const {
        if (root == NULL) {
            return 0.0;
        }

        int rank = 0;
        MotionTreap::Node *curr = root;
        while (curr != NULL) {
            if (MotionTreap::Node::Less(motion, curr.motion)) {
                curr = curr.left;
            } else {
                rank += MotionTreap::Node::GetSize(curr.left) + 1;
                curr = curr.right;
            }
        }
        return (double)rank / root.size * 100.0;
    }

private:
    Node *Erase(Node *nRoot, const Motion &motion) {
        if (nRoot == NULL)
            return NULL;

        if (MotionTreap::Node::Equals(nRoot.motion, motion)) {
            Node *temp = NULL;
            MotionTreap::Node::Merge(temp, nRoot.left, nRoot.right);
            MotionTreap::Node::UpdateSize(temp);
            delete nRoot;
            return temp;
        }

        if (MotionTreap::Node::Less(motion, nRoot.motion)) {
            nRoot.left = Erase(nRoot.left, motion);
            MotionTreap::Node::UpdateSize(nRoot.left);
        } else {
            nRoot.right = Erase(nRoot.right, motion);
            MotionTreap::Node::UpdateSize(nRoot.right);
        }

        MotionTreap::Node::UpdateSize(nRoot);
        return nRoot;
    }
};

}