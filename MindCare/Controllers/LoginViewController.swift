import UIKit

final class LoginViewController: UIViewController {
    private let nameField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel()
        title.text = "MindCare"
        title.font = .systemFont(ofSize: 34, weight: .bold)

        nameField.placeholder = "¿Cómo te llamas?"
        nameField.borderStyle = .roundedRect
        nameField.autocapitalizationType = .words

        var config = UIButton.Configuration.filled()
        config.title = "Entrar"
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(login), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, nameField, button])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        title.textAlignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func login() {
        let name = nameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else { return }
        StorageService.shared.saveUser(User(name: name, email: ""))
        navigationController?.pushViewController(WelcomeViewController(), animated: true)
    }
}