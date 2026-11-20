import Foundation

struct Emotion: Codable {
    let rating: Int      // 1...5 (estrellas)
    let date: Date
    var note: String?
}