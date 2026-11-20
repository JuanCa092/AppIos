import UIKit

final class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true

        let name = StorageService.shared.loadUser()?.name ?? ""
        let label = UILabel()
        label.text = "Bienvenido \(name)\n\n¿Empezamos?"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26, weight: .semibold)

        var config = UIButton.Configuration.filled()
        config.title = "Empezar"
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(start), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = 32
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func start() {
        navigationController?.pushViewController(HomeViewController(), animated: true)
    }
}