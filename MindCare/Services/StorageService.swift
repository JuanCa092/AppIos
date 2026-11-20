import Foundation

final class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard

    // MARK: Usuario
    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: "user")
        }
    }

    func loadUser() -> User? {
        guard let data = defaults.data(forKey: "user") else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    // MARK: Emociones (estrellas)
    func saveEmotion(_ emotion: Emotion) {
        var all = loadEmotions()
        all.append(emotion)
        if let data = try? JSONEncoder().encode(all) {
            defaults.set(data, forKey: "emotions")
        }
    }

    func loadEmotions() -> [Emotion] {
        guard let data = defaults.data(forKey: "emotions"),
              let list = try? JSONDecoder().decode([Emotion].self, from: data)
        else { return [] }
        return list
    }

    func clearEmotions() {
        defaults.removeObject(forKey: "emotions")
    }

    // MARK: Notas
    func loadNotes() -> [Note] {
        guard let data = defaults.data(forKey: "notes"),
              let list = try? JSONDecoder().decode([Note].self, from: data)
        else { return [] }
        return list
    }

    func saveNotes(_ notes: [Note]) {
        if let data = try? JSONEncoder().encode(notes) {
            defaults.set(data, forKey: "notes")
        }
    }

    // MARK: Mini tareas
    func loadTasks() -> [TaskItem] {
        guard let data = defaults.data(forKey: "tasks"),
              let list = try? JSONDecoder().decode([TaskItem].self, from: data)
        else {
            // Primera vez: tareas sugeridas
            return [TaskItem(title: "Respira profundo 1 minuto"),
                    TaskItem(title: "Toma un vaso de agua"),
                    TaskItem(title: "Escribe algo bueno de tu día"),
                    TaskItem(title: "Da un paseo corto")]
        }
        return list
    }

    func saveTasks(_ tasks: [TaskItem]) {
        if let data = try? JSONEncoder().encode(tasks) {
            defaults.set(data, forKey: "tasks")
        }
    }

    // MARK: Recordatorio
    var reminderEnabled: Bool {
        get { defaults.bool(forKey: "reminderEnabled") }
        set { defaults.set(newValue, forKey: "reminderEnabled") }
    }

    // MARK: Borrado total
    func clearAll() {
        ["user", "emotions", "notes", "tasks", "reminderEnabled"].forEach {
            defaults.removeObject(forKey: $0)
        }
    }
}