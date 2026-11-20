import UIKit

final class ChatViewController: UIViewController {

    private var messages: [ChatMessage] = [
        ChatMessage(role: .model, text: "Hola, soy tu acompañante de MindCare 💙 ¿Cómo te sientes hoy? Cuéntame lo que quieras.")
    ]
    private var isTyping = false

    private let tableView = UITableView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let crisisBanner = UIButton(type: .system)

    // Palabras de riesgo (sin tildes, en minúscula)
    private let riskWords = [
        "suicid", "quitarme la vida", "matarme", "acabar con todo", "no quiero vivir",
        "quiero morir", "hacerme dano", "cortarme", "terminar con mi vida", "no vale la pena vivir"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hablar con Gemini"
        view.backgroundColor = .systemBackground
        setupUI()

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }

    // MARK: UI
    private func setupUI() {
        // Banner de ayuda urgente (oculto hasta detectar riesgo)
        var bannerConfig = UIButton.Configuration.filled()
        bannerConfig.title = "Si estás en peligro, toca aquí: Ayuda urgente 113"
        bannerConfig.image = UIImage(systemName: "phone.fill")
        bannerConfig.imagePadding = 8
        bannerConfig.baseBackgroundColor = .systemRed
        bannerConfig.cornerStyle = .fixed
        crisisBanner.configuration = bannerConfig
        crisisBanner.isHidden = true
        crisisBanner.addTarget(self, action: #selector(openEmergency), for: .touchUpInside)

        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.register(BubbleCell.self, forCellReuseIdentifier: BubbleCell.id)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension

        let content = UIStackView(arrangedSubviews: [crisisBanner, tableView])
        content.axis = .vertical
        content.translatesAutoresizingMaskIntoConstraints = false

        // Barra de entrada
        let inputBar = UIView()
        inputBar.backgroundColor = .secondarySystemBackground
        inputBar.translatesAutoresizingMaskIntoConstraints = false

        inputField.placeholder = "Escribe un mensaje…"
        inputField.borderStyle = .roundedRect
        inputField.returnKeyType = .send
        inputField.delegate = self

        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        [inputField, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            inputBar.addSubview($0)
        }

        view.addSubview(content)
        view.addSubview(inputBar)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Sube con el teclado (iOS 15+)
            inputBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            inputField.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: 8),
            inputField.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor, constant: -8),
            inputField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),
            inputField.heightAnchor.constraint(equalToConstant: 38),

            sendButton.leadingAnchor.constraint(equalTo: inputField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 34),
            sendButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    // MARK: Envío
    @objc private func sendTapped() {
        let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty, !isTyping else { return }
        inputField.text = nil

        if containsRisk(text) { crisisBanner.isHidden = false }

        messages.append(ChatMessage(role: .user, text: text))
        setTyping(true)

        // Gemini exige que el historial empiece con un mensaje del usuario
        let history = Array(messages.drop(while: { $0.role == .model }))
        GeminiService.shared.send(history: history) { [weak self] result in
            guard let self = self else { return }
            self.setTyping(false)
            switch result {
            case .success(let reply):
                self.messages.append(ChatMessage(role: .model, text: reply))
            case .failure:
                self.messages.append(ChatMessage(role: .model,
                    text: "No pude responder ahora. Revisa tu conexión e inténtalo de nuevo. Si necesitas ayuda urgente, usa el botón rojo."))
            }
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }

    private func setTyping(_ value: Bool) {
        isTyping = value
        tableView.reloadData()
        scrollToBottom()
    }

    private func scrollToBottom() {
        let rows = tableView.numberOfRows(inSection: 0)
        guard rows > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: rows - 1, section: 0), at: .bottom, animated: true)
    }

    private func containsRisk(_ text: String) -> Bool {
        let clean = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        return riskWords.contains { clean.contains($0) }
    }

    @objc private func openEmergency() {
        navigationController?.pushViewController(EmergencyViewController(), animated: true)
    }
}

// MARK: - TableView
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count + (isTyping ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BubbleCell.id, for: indexPath) as! BubbleCell
        if indexPath.row < messages.count {
            let m = messages[indexPath.row]
            cell.configure(text: m.text, isUser: m.role == .user)
        } else {
            cell.configure(text: "Escribiendo…", isUser: false)
        }
        return cell
    }
}

// MARK: - TextField
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}

// MARK: - Burbuja
final class BubbleCell: UITableViewCell {
    static let id = "BubbleCell"

    private let bubble = UIView()
    private let label = UILabel()
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        bubble.layer.cornerRadius = 16
        bubble.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(bubble)
        bubble.addSubview(label)

        leadingConstraint = bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.78),

            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String, isUser: Bool) {
        label.text = text
        leadingConstraint.isActive = !isUser
        trailingConstraint.isActive = isUser
        bubble.backgroundColor = isUser ? .systemTeal : .secondarySystemBackground
        label.textColor = isUser ? .white : .label
    }
}