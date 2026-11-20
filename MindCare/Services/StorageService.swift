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
}