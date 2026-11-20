import UIKit

final class HomeViewController: UIViewController {
    private var starButtons: [UIButton] = []
    private let emojiLabel = UILabel()
    private let faces = ["😢", "🙁", "😐", "🙂", "😄"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true

        let name = StorageService.shared.loadUser()?.name ?? ""

        // Saludo
        let greeting = UILabel()
        greeting.text = "¡Hola \(name)!"
        greeting.font = .systemFont(ofSize: 30, weight: .bold)
        greeting.textAlignment = .center

        let question = UILabel()
        question.text = "¿Cómo te sientes hoy?"
        question.font = .systemFont(ofSize: 17)
        question.textColor = .secondaryLabel
        question.textAlignment = .center

        // Estrellas
        let starsStack = UIStackView()
        starsStack.axis = .horizontal
        starsStack.spacing = 8
        starsStack.distribution = .fillEqually
        for i in 1...5 {
            let b = UIButton(type: .system)
            b.setImage(UIImage(systemName: "star"), for: .normal)
            b.tintColor = .systemYellow
            b.tag = i
            b.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(b)
            starsStack.addArrangedSubview(b)
        }

        // Emoji
        emojiLabel.text = "😐"
        emojiLabel.font = .systemFont(ofSize: 72)
        emojiLabel.textAlignment = .center

        // Botones
        let buttons = UIStackView(arrangedSubviews: [
            makeButton("Ejercicios de respiración", "wind", #selector(openExercises)),
            makeButton("Hablar con Gemini", "bubble.left.and.bubble.right", #selector(openChat)),
            makeButton("Ayuda urgente (línea contra el suicidio 113)", "phone.fill", #selector(openEmergency), color: .systemRed),
            makeButton("Ver más", "ellipsis.circle", #selector(openMore))
        ])
        buttons.axis = .vertical
        buttons.spacing = 12

        let main = UIStackView(arrangedSubviews: [greeting, question, starsStack, emojiLabel, buttons])
        main.axis = .vertical
        main.spacing = 20
        main.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(main)
        NSLayoutConstraint.activate([
            main.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            main.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            main.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            starsStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func makeButton(_ title: String, _ icon: String, _ action: Selector,
                            color: UIColor = .systemTeal) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.baseBackgroundColor = color
        config.titleLineBreakMode = .byWordWrapping
        let b = UIButton(configuration: config)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    // MARK: Estrellas
    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        for b in starButtons {
            let name = b.tag <= rating ? "star.fill" : "star"
            b.setImage(UIImage(systemName: name), for: .normal)
        }
        UIView.transition(with: emojiLabel, duration: 0.25, options: .transitionCrossDissolve) {
            self.emojiLabel.text = self.faces[rating - 1]
        }
        StorageService.shared.saveEmotion(Emotion(rating: rating, date: Date(), note: nil))

        // Si se siente muy mal, ofrecer ayuda
        if rating <= 2 {
            let alert = UIAlertController(
                title: "Lamento que te sientas así",
                message: "No estás solo/a. ¿Quieres hablar con alguien o hacer un ejercicio?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ejercicio", style: .default) { _ in self.openExercises() })
            alert.addAction(UIAlertAction(title: "Hablar con Gemini", style: .default) { _ in self.openChat() })
            alert.addAction(UIAlertAction(title: "Ahora no", style: .cancel))
            present(alert, animated: true)
        }
    }

    // MARK: Navegación
    @objc private func openExercises() { navigationController?.pushViewController(ExercisesViewController(), animated: true) }
    @objc private func openChat()      { navigationController?.pushViewController(ChatViewController(), animated: true) }
    @objc private func openEmergency() { navigationController?.pushViewController(EmergencyViewController(), animated: true) }

    @objc private func openMore() {
        let sheet = UIAlertController(title: "Ver más", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Diario / bloc de notas", style: .default) { _ in
            self.navigationController?.pushViewController(DiaryViewController(), animated: true)
        })
        sheet.addAction(UIAlertAction(title: "Mini tareas", style: .default) { _ in
            self.navigationController?.pushViewController(DiaryViewController(), animated: true)
        })
        sheet.addAction(UIAlertAction(title: "Perfil", style: .default) { _ in
            self.navigationController?.pushViewController(ProfileViewController(), animated: true)
        })
        sheet.addAction(UIAlertAction(title: "Ajustes", style: .default) { _ in
            self.navigationController?.pushViewController(ProfileViewController(), animated: true)
        })
        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(sheet, animated: true)
    }
}