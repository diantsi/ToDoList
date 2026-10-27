//
//  ViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 07.10.2026.
//

import UIKit

class ViewController: UITableViewController {

    var persistenceService: any PersistenceService!
    private var tasks: [TodoTask] = []

    private var notificationService : UserNotificationsService {
        return UserNotificationsService.shared
    }

    override func viewDidLoad() {
        persistenceService = PersistenceServiceProvider.shared

        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(todoTasksDidChange),
            name: .todoTasksDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
    }

    private func loadTasks() {
        do {
            tasks = try persistenceService.getAllTasks(isHidden: false)
            tableView.reloadData()
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }

    @objc private func todoTasksDidChange() {
        loadTasks()
    }

    @IBAction func addTaskTapped(_ sender: UIBarButtonItem) {
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tasks.count
    }

    override func tableView (
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "task_cell",
                for: indexPath
            ) as? TaskCell
        else {
            return UITableViewCell()
        }

        let task = tasks[indexPath.row]
        cell.configure(with: task)

        cell.onToggle = { [weak self] in
            self?.toggleTask(id: task.id)
        }

        return cell
    }
    


    private func toggleTask(id: UUID) {
        do {
            try persistenceService.toggleTaskDone(id: id)
            loadTasks()
        } catch {
            showToggleError(error)
        }
    }

    private func showToggleError(_ error: Error) {
        let alert = UIAlertController(
            title: "Не вдалося оновити завдання",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(alert, animated: true)
    }

    private func sendNotification(for reminderItem: any ReminderItem) {
        Task { [weak self] in
            guard let self else {
                return
            }

            do {
                try await notificationService.sendNotification(
                    with: reminderItem
                )
            } catch NotificationError.notificationAccessDenied {
                showNotificationAccessAlert()
            } catch {
                showToggleError(error)
            }
        }
    }

    private func showNotificationAccessAlert() {
        let alert = UIAlertController(
            title: "Сповіщення вимкнені",
            message: "Дозвольте сповіщення для ToDo в налаштуваннях пристрою",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        let task = tasks[indexPath.row]

        do {
            try persistenceService.deleteTask(id: task.id)
            notificationService.cancelNotification(with: task)
            for subtask in task.subtasks {
                notificationService.cancelNotification(with: subtask)
            }
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(
                at: [indexPath],
                with: .automatic
            )
        } catch {
            let alert = UIAlertController(
                title: "Не вдалося видалити",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "OK", style: .default)
            )

            present(alert, animated: true)
        }
    }
    
    override func tableView( _ tableView: UITableView,
                             didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        performSegue(withIdentifier: "ShowSubtasks", sender: task)
    }

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        switch segue.identifier {
        case "ShowAddTask":
            prepareAddTaskSegue(segue)

        case "ShowSubtasks":
            prepareSubtasksSegue(
                segue,
                sender: sender
            )

        default:
            break
        }
    }

    private func prepareAddTaskSegue(
        _ segue: UIStoryboardSegue
    ) {
        guard
            let navigationController =
                segue.destination as? UINavigationController,
            let addTaskVC =
                navigationController.topViewController
                as? AddTaskViewController
        else {
            return
        }

        addTaskVC.isSubtask = false

        addTaskVC.onSave = { [weak self] name, date, needToNotify in
            guard let self else {
                return
            }

            let task = TodoTask(
                name: name,
                dueDate: date,
                needToNotify: needToNotify
            )

            try persistenceService.addTask(task)
            
            if needToNotify {
                sendNotification(for: task)
            }
            loadTasks()
        }
    }

    private func prepareSubtasksSegue(
        _ segue: UIStoryboardSegue,
        sender: Any?
    ) {
        guard
            let subtaskListVC =
                segue.destination as? SubtaskListViewController,
            let selectedTask = sender as? TodoTask
        else {
            return
        }

        subtaskListVC.persistenceService = persistenceService
        subtaskListVC.task = selectedTask

    }

}
