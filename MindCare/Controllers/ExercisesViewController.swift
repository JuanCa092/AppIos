import UIKit

final class ExercisesViewController: UIViewController {

    private struct Phase {
        let text: String
        let seconds: Double
        let scale: CGFloat
    }

    private struct Exercise {
        let title: String
        let description: String
        let phases: [Phase]
    }

    private let exercises: [Exercise] = [
        Exercise(title: "Contra la ansiedad",
                 description: "Respiración 4-7-8",
                 phases: [Phase(text: "Inhala", seconds: 4, scale: 1.0),
                          Phase(text: "Sostén", seconds: 7, scale: 1.0),
                          Phase(text: "Exhala", seconds: 8, scale: 0.5)]),
        Exercise(title: "Contra los nervios",
                 description: "Respiración cuadrada 4-4-4-4",
                 phases: [Phase(text: "Inhala", seconds: 4, scale: 1.0),
                          Phase(text: "Sostén", seconds: 4, scale: 1.0),
                          Phase(text: "Exhala", seconds: 4, scale: 0.5),
                          Phase(text: "Pausa", seconds: 4, scale: 0.5)]),
        Exercise(title: "Para calmar la ira",
                 description: "Exhalación larga 4-6",
                 phases: [Phase(text: "Inhala", seconds: 4, scale: 1.0),
                          Phase(text: "Exhala lentamente", seconds: 6, scale: 0.5)])
    ]

    private let circle = UIView()
    private let phaseLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var session = 0   // sirve para cancelar la animación anterior

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ejercicios"
        view.backgroundColor = .systemBackground

        // Botones de ejercicios
        let buttons = UIStackView()
        buttons.axis = .vertical
        buttons.spacing = 12
        for (i, ex) in exercises.enumerated() {
            var config = UIButton.Configuration.tinted()
            config.title = ex.title
            let b = UIButton(configuration: config)
            b.tag = i
            b.addTarget(self, action: #selector(exerciseTapped(_:)), for: .touchUpInside)
            buttons.addArrangedSubview(b)
        }

        // Círculo que respira
        circle.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.5)
        circle.layer.cornerRadius = 100
        circle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        phaseLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        phaseLabel.textAlignment = .center
        phaseLabel.text = "Elige un ejercicio"

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center

        var stopConfig = UIButton.Configuration.plain()
        stopConfig.title = "Detener"
        let stop = UIButton(configuration: stopConfig)
        stop.addTarget(self, action: #selector(stopExercise), for: .touchUpInside)

        [buttons, circle, phaseLabel, descriptionLabel, stop].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            buttons.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            circle.widthAnchor.constraint(equalToConstant: 200),
            circle.heightAnchor.constraint(equalToConstant: 200),
            circle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circle.topAnchor.constraint(equalTo: buttons.bottomAnchor, constant: 50),

            phaseLabel.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 40),
            phaseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            phaseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            descriptionLabel.topAnchor.constraint(equalTo: phaseLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stop.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            stop.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopExercise()
    }

    @objc private func exerciseTapped(_ sender: UIButton) {
        let exercise = exercises[sender.tag]
        stopExercise()
        descriptionLabel.text = exercise.description
        circle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        run(exercise, phase: 0, token: session)
    }

    @objc private func stopExercise() {
        session += 1
        circle.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3) {
            self.circle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        phaseLabel.text = "Elige un ejercicio"
        descriptionLabel.text = nil
    }

    private func run(_ exercise: Exercise, phase: Int, token: Int) {
        guard token == session else { return }
        let p = exercise.phases[phase % exercise.phases.count]
        phaseLabel.text = p.text
        UIView.animate(withDuration: p.seconds, delay: 0, options: [.curveEaseInOut]) {
            self.circle.transform = CGAffineTransform(scaleX: p.scale, y: p.scale)
        } completion: { _ in
            self.run(exercise, phase: phase + 1, token: token)
        }
    }
}