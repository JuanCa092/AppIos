import Foundation

struct ChatMessage {
    enum Role: String { case user, model }
    let role: Role
    let text: String
}

final class GeminiService {
    static let shared = GeminiService()

    // No subas la clave a git. Para producción, usa un backend propio que la guarde.
    private let apiKey = "TU_API_KEY"
    private let model = "gemini-2.5-flash"   // verifica el nombre vigente en Google AI Studio

    private let systemPrompt = """
    Eres el acompañante de bienestar emocional de la app MindCare. Responde en español, \
    con calidez, empatía y brevedad (máximo 4 o 5 frases). Escucha primero y luego sugiere, \
    por ejemplo un ejercicio de respiración de la app. No diagnostiques ni reemplaces a un \
    profesional. Si la persona menciona suicidio, autolesión o está en peligro, valida lo que \
    siente, anímala a usar el botón de Ayuda urgente (113 en Perú) y a hablar con alguien de confianza.
    """

    func send(history: [ChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 30
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        let contents = history.map { msg -> [String: Any] in
            ["role": msg.role.rawValue, "parts": [["text": msg.text]]]
        }
        let body: [String: Any] = [
            "system_instruction": ["parts": [["text": systemPrompt]]],
            "contents": contents
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, response, error in
            let finish: (Result<String, Error>) -> Void = { result in
                DispatchQueue.main.async { completion(result) }
            }
            if let error = error { return finish(.failure(error)) }

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                return finish(.failure(NSError(domain: "Gemini", code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Error del servidor (\(http.statusCode))"])))
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let cand = (json["candidates"] as? [[String: Any]])?.first,
                  let content = cand["content"] as? [String: Any],
                  let part = (content["parts"] as? [[String: Any]])?.first,
                  let reply = part["text"] as? String
            else {
                return finish(.failure(NSError(domain: "Gemini", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Respuesta inesperada"])))
            }
            finish(.success(reply))
        }.resume()
    }
}