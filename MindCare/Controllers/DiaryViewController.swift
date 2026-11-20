import UIKit

final class DiaryViewController: UIViewController {

    private var notes: [Note] = []
    private var tasks: [TaskItem] = []

    private let segmented = UISegmentedControl(items: ["Notas", "Mini tareas"])
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel = UILabel()
    private let startOnTasks: Bool

    private var showingNotes: Bool { segmented.selectedSegmentIndex == 0 }

    init(startOnTasks: Bool = false) {
        self.startOnTasks = startOnTasks
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diario"
        view.backgroundColor = .systemBackground

        notes = StorageService.shared.loadNotes()
        tasks = StorageService.shared.loadTasks()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        segmented.selectedSegmentIndex = startOnTasks ? 1 : 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0

        view.addSubview(segmented)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        refresh()
    }

    // MARK: Acciones
    @objc private func segmentChanged() { refresh() }

    @objc private func addTapped() {
        if showingNotes { editNote(at: nil) } else { editTask(at: nil) }
    }

    private func refresh() {
        let isEmpty = showingNotes ? notes.isEmpty : tasks.isEmpty
        emptyLabel.text = showingNotes
            ? "Aún no tienes notas.\nToca + para escribir lo que sientes."
            : "No tienes mini tareas.\nToca + para agregar una."
        tableView.backgroundView = isEmpty ? emptyLabel : nil
        tableView.reloadData()
    }

    // MARK: Notas
    private func editNote(at index: Int?) {
        let alert = UIAlertController(title: index == nil ? "Nueva nota" : "Editar nota",
                                      message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "¿Qué tienes en mente?"
            tf.text = index.map { self.notes[$0].text }
            tf.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
            let text = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !text.isEmpty else { return }
            if let i = index {
                self.notes[i].text = text
            } else {
                self.notes.insert(Note(text: text), at: 0)   // la más nueva arriba
            }
            StorageService.shared.saveNotes(self.notes)
            self.refresh()
        })
        present(alert, animated: true)
    }

    // MARK: Tareas
    private func editTask(at index: Int?) {
        let alert = UIAlertController(title: index == nil ? "Nueva mini tarea" : "Editar mini tarea",
                                      message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Ej: Estirarme 5 minutos"
            tf.text = index.map { self.tasks[$0].title }
            tf.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
            let text = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !text.isEmpty else { return }
            if let i = index {
                self.tasks[i].title = text
            } else {
                self.tasks.append(TaskItem(title: text))
            }
            StorageService.shared.saveTasks(self.tasks)
            self.refresh()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView
extension DiaryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showingNotes ? notes.count : tasks.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !showingNotes else { return nil }
        let done = tasks.filter { $0.isDoneToday }.count
        return tasks.isEmpty ? nil : "Hoy: \(done) de \(tasks.count) completadas"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()

        if showingNotes {
            let n = notes[indexPath.row]
            content.text = n.text
            content.textProperties.numberOfLines = 0
            content.secondaryText = Self.dateFormatter.string(from: n.date)
            content.secondaryTextProperties.color = .secondaryLabel
            cell.accessoryType = .none
        } else {
            let t = tasks[indexPath.row]
            content.text = t.title
            content.textProperties.numberOfLines = 0
            content.image = UIImage(systemName: t.isDoneToday ? "checkmark.circle.fill" : "circle")
            content.imageProperties.tintColor = t.isDoneToday ? .systemGreen : .systemGray
            content.textProperties.color = t.isDoneToday ? .secondaryLabel : .label
        }
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if showingNotes {
            editNote(at: indexPath.row)
        } else {
            // Marcar / desmarcar por hoy
            tasks[indexPath.row].lastDone = tasks[indexPath.row].isDoneToday ? nil : Date()
            StorageService.shared.saveTasks(tasks)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []

        let delete = UIContextualAction(style: .destructive, title: "Borrar") { _, _, done in
            if self.showingNotes {
                self.notes.remove(at: indexPath.row)
                StorageService.shared.saveNotes(self.notes)
            } else {
                self.tasks.remove(at: indexPath.row)
                StorageService.shared.saveTasks(self.tasks)
            }
            self.refresh()
            done(true)
        }
        actions.append(delete)

        if !showingNotes {
            let edit = UIContextualAction(style: .normal, title: "Editar") { _, _, done in
                self.editTask(at: indexPath.row)
                done(true)
            }
            edit.backgroundColor = .systemBlue
            actions.append(edit)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_PE")
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
}