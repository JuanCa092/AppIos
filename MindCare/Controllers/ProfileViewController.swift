import UIKit
import UserNotifications

final class ProfileViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private enum Section: Int, CaseIterable {
        case profile, summary, settings, data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Perfil y ajustes"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: Datos calculados
    private var userName: String { StorageService.shared.loadUser()?.name ?? "" }

    private var averageText: String {
        let list = StorageService.shared.loadEmotions()
        guard !list.isEmpty else { return "—" }
        let avg = Double(list.map { $0.rating }.reduce(0, +)) / Double(list.count)
        return String(format: "%.1f ★", avg)
    }

    // MARK: Cambiar nombre
    private func editName() {
        let alert = UIAlertController(title: "Cambiar nombre", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = self.userName
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
            let name = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            var user = StorageService.shared.loadUser() ?? User(name: name, email: "")
            user.name = name
            StorageService.shared.saveUser(user)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }

    // MARK: Recordatorio diario
    @objc private func reminderToggled(_ sender: UISwitch) {
        let center = UNUserNotificationCenter.current()
        if sender.isOn {
            center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        StorageService.shared.reminderEnabled = true
                        self.scheduleReminder()
                    } else {
                        sender.setOn(false, animated: true)
                        StorageService.shared.reminderEnabled = false
                        let a = UIAlertController(
                            title: "Notificaciones desactivadas",
                            message: "Actívalas en Ajustes del iPhone > MindCare para recibir el recordatorio.",
                            preferredStyle: .alert)
                        a.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(a, animated: true)
                    }
                }
            }
        } else {
            StorageService.shared.reminderEnabled = false
            center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        }
    }

    private func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "MindCare 💙"
        content.body = "¿Cómo te sientes hoy? Tómate un minuto para ti."
        content.sound = .default

        var date = DateComponents()
        date.hour = 20          // 8:00 pm
        date.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: Borrado
    private func confirmClearEmotions() {
        let a = UIAlertController(title: "Borrar historial de ánimo",
                                  message: "Se eliminarán todas tus calificaciones con estrellas.",
                                  preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        a.addAction(UIAlertAction(title: "Borrar", style: .destructive) { _ in
            StorageService.shared.clearEmotions()
            self.tableView.reloadData()
        })
        present(a, animated: true)
    }

    private func confirmLogout() {
        let a = UIAlertController(title: "Cerrar sesión",
                                  message: "Se borrarán tu nombre, notas, tareas e historial de este dispositivo.",
                                  preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        a.addAction(UIAlertAction(title: "Borrar todo", style: .destructive) { _ in
            StorageService.shared.clearAll()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            self.navigationController?.setViewControllers([LoginViewController()], animated: true)
        })
        present(a, animated: true)
    }
}

// MARK: - TableView
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .profile:  return 1
        case .summary:  return 3
        case .settings: return 2
        case .data:     return 2
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .profile:  return "Perfil"
        case .summary:  return "Tu resumen"
        case .settings: return "Ajustes"
        case .data:     return "Datos"
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .data:
            return "MindCare es un acompañante de bienestar y no reemplaza la atención de un profesional de la salud mental. Si estás en peligro, llama al 113."
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()

        switch Section(rawValue: indexPath.section)! {
        case .profile:
            content.text = userName
            content.secondaryText = "Cambiar"
            content.image = UIImage(systemName: "person.circle.fill")
            content.imageProperties.tintColor = .systemTeal
            cell.accessoryType = .disclosureIndicator

        case .summary:
            let emotions = StorageService.shared.loadEmotions()
            let tasks = StorageService.shared.loadTasks()
            switch indexPath.row {
            case 0:
                content.text = "Registros de ánimo"
                content.secondaryText = "\(emotions.count)"
            case 1:
                content.text = "Promedio"
                content.secondaryText = averageText
            default:
                content.text = "Tareas de hoy"
                content.secondaryText = "\(tasks.filter { $0.isDoneToday }.count) de \(tasks.count)"
            }
            cell.selectionStyle = .none

        case .settings:
            if indexPath.row == 0 {
                content.text = "Recordatorio diario (8:00 pm)"
                let toggle = UISwitch()
                toggle.isOn = StorageService.shared.reminderEnabled
                toggle.addTarget(self, action: #selector(reminderToggled(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            } else {
                content.text = "Línea de ayuda"
                content.secondaryText = "113 (Perú)"
            }
            cell.selectionStyle = .none

        case .data:
            if indexPath.row == 0 {
                content.text = "Borrar historial de ánimo"
                content.textProperties.color = .systemRed
            } else {
                content.text = "Cerrar sesión y borrar todo"
                content.textProperties.color = .systemRed
            }
        }

        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .profile:
            editName()
        case .data:
            indexPath.row == 0 ? confirmClearEmotions() : confirmLogout()
        default:
            break
        }
    }
}