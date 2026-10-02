#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

class Email {
public:
    std::string sender;
    std::string subject;
    std::string date;
    int senderPriority;
    int dateKey;
    unsigned long long sequence;

    Email(const std::string& senderValue, const std::string& subjectValue,
          const std::string& dateValue, unsigned long long sequenceValue)
        : sender(senderValue), subject(subjectValue), date(dateValue),
          senderPriority(0), dateKey(0), sequence(sequenceValue) {
        if (sender == "Boss") senderPriority = 5;
        else if (sender == "Subordinate") senderPriority = 4;
        else if (sender == "Peer") senderPriority = 3;
        else if (sender == "ImportantPerson") senderPriority = 2;
        else senderPriority = 1;

        // MM-DD-YYYY is converted to YYYYMMDD so integer order matches date order.
        if (date.size() == 10) {
            dateKey = (date[6] - '0') * 10000000 + (date[7] - '0') * 1000000 +
                      (date[8] - '0') * 100000 + (date[9] - '0') * 10000 +
                      (date[0] - '0') * 1000 + (date[1] - '0') * 100 +
                      (date[3] - '0') * 10 + (date[4] - '0');
        }
    }

    bool outranks(const Email& other) const {
        if (senderPriority != other.senderPriority)
            return senderPriority > other.senderPriority;
        if (dateKey != other.dateKey) return dateKey > other.dateKey;
        return sequence < other.sequence;
    }
};

class MaxHeap {
private:
    std::vector<Email> items;

    void swapItems(std::size_t first, std::size_t second) {
        Email temp = items[first];
        items[first] = items[second];
        items[second] = temp;
    }

    void siftUp(std::size_t index) {
        while (index > 0) {
            std::size_t parent = (index - 1) / 2;
            if (!items[index].outranks(items[parent])) break;
            swapItems(index, parent);
            index = parent;
        }
    }

    void siftDown(std::size_t index) {
        while (true) {
            std::size_t left = index * 2 + 1;
            std::size_t right = index * 2 + 2;
            std::size_t best = index;
            if (left < items.size() && items[left].outranks(items[best])) best = left;
            if (right < items.size() && items[right].outranks(items[best])) best = right;
            if (best == index) break;
            swapItems(index, best);
            index = best;
        }
    }

public:
    bool empty() const { return items.empty(); }
    std::size_t size() const { return items.size(); }

    void insert(const Email& email) {
        items.push_back(email);
        siftUp(items.size() - 1);
    }

    const Email* top() const {
        return items.empty() ? nullptr : &items[0];
    }

    void removeTop() {
        if (items.empty()) return;
        if (items.size() == 1) {
            items.pop_back();
            return;
        }
        items[0] = items.back();
        items.pop_back();
        siftDown(0);
    }
};

class EmailQueueProgram {
private:
    MaxHeap inbox;
    unsigned long long nextSequence = 0;

    void handleEmail(const std::string& line) {
        std::string fields = line.substr(6);
        std::size_t firstComma = fields.find(',');
        std::size_t secondComma = fields.find(',', firstComma == std::string::npos ? firstComma : firstComma + 1);
        if (firstComma == std::string::npos || secondComma == std::string::npos) return;

        std::string sender = fields.substr(0, firstComma);
        std::string subject = fields.substr(firstComma + 1, secondComma - firstComma - 1);
        std::string date = fields.substr(secondComma + 1);
        inbox.insert(Email(sender, subject, date, nextSequence++));
    }

    void handleLine(const std::string& line) {
        if (line.compare(0, 6, "EMAIL ") == 0) {
            handleEmail(line);
        } else if (line == "COUNT") {
            std::cout << "There are " << inbox.size() << " emails to read.\n";
        } else if (line == "NEXT") {
            const Email* email = inbox.top();
            if (email == nullptr) return;
            std::cout << "Next email:\n"
                      << "Sender: " << email->sender << '\n'
                      << "Subject: " << email->subject << '\n'
                      << "Date: " << email->date << '\n';
        } else if (line == "READ") {
            inbox.removeTop();
        }
    }

public:
    void run(std::istream& input) {
        std::string line;
        while (std::getline(input, line)) {
            if (!line.empty() && line.back() == '\r') line.pop_back();
            handleLine(line);
        }
    }
};

int main(int argc, char* argv[]) {
    std::ifstream file;
    std::istream* input = &std::cin;
    if (argc > 1) {
        file.open(argv[1]);
        if (!file) return 0;
        input = &file;
    }

    EmailQueueProgram program;
    program.run(*input);
    return 0;
}
