import Foundation

struct Note: Codable {
    let id: UUID
    var text: String
    let date: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.date = Date()
    }
}

struct TaskItem: Codable {
    let id: UUID
    var title: String
    var lastDone: Date?

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.lastDone = nil
    }

    // Se reinicia sola cada día
    var isDoneToday: Bool {
        guard let d = lastDone else { return false }
        return Calendar.current.isDateInToday(d)
    }
}