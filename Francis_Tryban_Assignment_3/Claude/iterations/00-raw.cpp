#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
using namespace std;

bool dateGreater(string date1, string date2) {
    int mm1 = stoi(date1.substr(0, 2));
    int dd1 = stoi(date1.substr(3, 2));
    int yyyy1 = stoi(date1.substr(6, 4));

    int mm2 = stoi(date2.substr(0, 2));
    int dd2 = stoi(date2.substr(3, 2));
    int yyyy2 = stoi(date2.substr(6, 4));

    if (yyyy1 != yyyy2) return yyyy1 > yyyy2;
    if (mm1 != mm2) return mm1 > mm2;
    return dd1 > dd2;
}

class Email {
public:
    string sender;
    string subject;
    string date;
    int priority;

    Email() : sender(""), subject(""), date(""), priority(0) {}
    Email(string s, string sub, string d, int p)
        : sender(s), subject(sub), date(d), priority(p) {}

    bool operator>(const Email& other) const {
        if (priority != other.priority) {
            return priority > other.priority;
        }
        return dateGreater(date, other.date);
    }
};

class MaxHeap {
private:
    vector<Email> heap;

    int parent(int i) {
        return (i - 1) / 2;
    }

    int leftChild(int i) {
        return 2 * i + 1;
    }

    int rightChild(int i) {
        return 2 * i + 2;
    }

    void bubbleUp(int i) {
        while (i > 0 && heap[i] > heap[parent(i)]) {
            swap(heap[i], heap[parent(i)]);
            i = parent(i);
        }
    }

    void bubbleDown(int i) {
        int largest = i;
        int left = leftChild(i);
        int right = rightChild(i);

        if (left < (int)heap.size() && heap[left] > heap[largest]) {
            largest = left;
        }

        if (right < (int)heap.size() && heap[right] > heap[largest]) {
            largest = right;
        }

        if (largest != i) {
            swap(heap[i], heap[largest]);
            bubbleDown(largest);
        }
    }

public:
    void push(Email email) {
        heap.push_back(email);
        bubbleUp(heap.size() - 1);
    }

    Email pop() {
        Email max = heap[0];
        heap[0] = heap[heap.size() - 1];
        heap.pop_back();
        if (heap.size() > 0) {
            bubbleDown(0);
        }
        return max;
    }

    Email peek() const {
        return heap[0];
    }

    bool empty() const {
        return heap.size() == 0;
    }

    int size() const {
        return heap.size();
    }
};

int getPriority(string category) {
    if (category == "Boss") return 5;
    if (category == "Subordinate") return 4;
    if (category == "Peer") return 3;
    if (category == "ImportantPerson") return 2;
    if (category == "OtherPerson") return 1;
    return 0;
}

string trim(string s) {
    size_t start = s.find_first_not_of(" \t\n\r");
    size_t end = s.find_last_not_of(" \t\n\r");
    if (start == string::npos) return "";
    return s.substr(start, end - start + 1);
}

int main(int argc, char* argv[]) {
    MaxHeap emailQueue;

    istream* input = &cin;
    ifstream file;

    if (argc > 1) {
        file.open(argv[1]);
        input = &file;
    }

    string line;
    while (getline(*input, line)) {
        if (line.empty()) continue;

        stringstream ss(line);
        string command;
        ss >> command;

        if (command == "EMAIL") {
            string sender, subject, date;
            getline(ss, sender, ',');
            getline(ss, subject, ',');
            getline(ss, date);

            sender = trim(sender);
            subject = trim(subject);
            date = trim(date);

            int priority = getPriority(sender);
            Email email(sender, subject, date, priority);
            emailQueue.push(email);
        }
        else if (command == "COUNT") {
            cout << "There are " << emailQueue.size() << " emails to read." << endl;
        }
        else if (command == "NEXT") {
            if (!emailQueue.empty()) {
                Email current = emailQueue.peek();
                cout << "Next email:" << endl;
                cout << "Sender: " << current.sender << endl;
                cout << "Subject: " << current.subject << endl;
                cout << "Date: " << current.date << endl;
            }
        }
        else if (command == "READ") {
            if (!emailQueue.empty()) {
                emailQueue.pop();
            }
        }
    }

    if (argc > 1) {
        file.close();
    }

    return 0;
}
