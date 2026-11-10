//
//  SubtaskListViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//

import UIKit

final class SubtaskListViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate
{
    @IBOutlet weak var navigationAddButton: UIBarButtonItem!
    
    @IBOutlet weak var subtasksTitleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var notificationStackView: UIStackView!
    @IBOutlet private weak var notificationSwitch: UISwitch!

    var persistenceService: (any PersistenceService)!
    var task: TodoTask!
    private var subtasks: [TodoSubtask] = []


    private var notificationService: UserNotificationsService {
        return UserNotificationsService.shared
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        
        configureAccessibility()

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (self: Self, _: UITraitCollection) in
            self.updateDynamicTypeLayout()
        }
        updateDynamicTypeLayout()
    }

    private func updateDynamicTypeLayout() {
        let usesAccessibilityCategory = traitCollection
            .preferredContentSizeCategory.isAccessibilityCategory

        notificationStackView.axis =
            usesAccessibilityCategory ? .vertical : .horizontal
        notificationStackView.alignment =
            usesAccessibilityCategory ? .fill : .center
        notificationSwitch.contentHorizontalAlignment =
            usesAccessibilityCategory ? .leading : .center

        let metrics = UIFontMetrics(forTextStyle: .body)
        notificationStackView.spacing = metrics.scaledValue(for: 8)
    }
    
    private func configureAccessibility() {
        navigationAddButton.accessibilityLabel = "Додати підзавдання"
        subtasksTitleLabel.accessibilityTraits.insert(.header)
        notificationSwitch.isAccessibilityElement = true
        notificationSwitch.accessibilityLabel = "Нагадувати про завдання"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = task.name
        notificationSwitch.isOn = task.needToNotify
        loadSubtasks()
    }

    private func loadSubtasks() {
        do {
            subtasks = try persistenceService.getSubtasks(
                for: task.id
            )

            tableView.reloadData()
        } catch {
            showError(title: "Не можливо завантажити завдання", error)
            return
        }
    }

    @IBAction private func notificationSwitchChanged(_ sender: UISwitch) {
        let needToNotify = sender.isOn
        do {
            try persistenceService.setTaskNotificationEnabled(
                needToNotify,
                for: task.id
            )
        } catch {
            showError(title: "Не вдалося оновити завдання", error)
            return
        }
        if needToNotify {
            sendNotification(for: task)
        } else {
            notificationService.cancelNotification(with: task)
        }
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return subtasks.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "subtask_cell",
                for: indexPath
            ) as? SubtaskCell
        else {
            return UITableViewCell()
        }

        let subtask = subtasks[indexPath.row]
        cell.configure(with: subtask)

        cell.onToggle = { [weak self] in
            self?.toggleSubtask(id: subtask.id)
        }
        
        cell.onNotificationChange = { [weak self] isOn in
            self?.setUpNotification(needToNotify: isOn, for: subtask)
        }

        cell.onDelete = { [weak self] in
            self?.deleteSubtask(id: subtask.id)
        }

        return cell
    }

    private func setUpNotification(needToNotify: Bool, for subtask: TodoSubtask)
    {
        guard
            let index = subtasks.firstIndex(
                where: { $0.id == subtask.id }
            )
        else {
            return
        }

        do {
            try persistenceService.setSubtaskNotificationEnabled(
                needToNotify,
                for: subtask.id
            )
        } catch {
            reloadSubtask(at: index)
            showError(title: "Не вдалося оновити завдання", error)
            return
        }

        subtasks[index].needToNotify = needToNotify
        reloadSubtask(at: index)

        if needToNotify {
            sendNotification(
                for: subtasks[index],
                successAnnouncement: "Сповіщення увімкнені"
            )
        } else {
            notificationService.cancelNotification(with: subtask)

            UIAccessibility.post(
                notification: .announcement,
                argument: "Сповіщення вимкнені"
            )
        }
    }

    private func toggleSubtask(id: UUID) {
        guard
            let index = subtasks.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }

        let newIsDone = !subtasks[index].isDone

        do {
            try persistenceService.toggleSubtaskDone(id: id)

            subtasks[index].isDone = newIsDone
            reloadSubtask(at: index)

            UIAccessibility.post(
                notification: .announcement,
                argument: newIsDone
                    ? "Підзавдання позначено виконаним"
                    : "Підзавдання позначено невиконаним"
            )
        } catch {
            showError(title: "Не вдалося оновити завдання", error)
        }
    }

    private func reloadSubtask(at index: Int) {
        tableView.reloadRows(
            at: [IndexPath(row: index, section: 0)],
            with: UIAccessibility.isReduceMotionEnabled
                ? .none
                : .automatic
        )
    }

    private func showError(title: String,_ error: Error) {
        let alert = UIAlertController(
            title: title,
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

    private func sendNotification(
        for reminderItem: any ReminderItem,
        successAnnouncement: String? = nil
    ) {
        Task { [weak self] in
            guard let self else {
                return
            }

            do {
                try await notificationService.sendNotification(
                    with: reminderItem
                )

                if let successAnnouncement {
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: successAnnouncement
                    )
                }
            } catch NotificationError.notificationAccessDenied {
                showNotificationAccessAlert()
            } catch {
                showError(title: "Не вдалося оновити завдання", error)
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

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        deleteSubtask(id: subtasks[indexPath.row].id)
    }

    private func deleteSubtask(id: UUID) {
        guard
            let index = subtasks.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        let subtask = subtasks[index]

        do {
            try persistenceService.deleteSubtask(id: id)
            notificationService.cancelNotification(with: subtask)
            subtasks.remove(at: index)
            tableView.deleteRows(
                at: [indexPath],
                with: UIAccessibility.isReduceMotionEnabled
                    ? .none
                    : .automatic
            )
            UIAccessibility.post(
                notification: .announcement,
                argument: "Підзавдання видалено"
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

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        guard segue.identifier == "ShowAddSubtask",
            let navigationController =
                segue.destination as? UINavigationController,
            let addTaskVC =
                navigationController.topViewController as? AddTaskViewController
        else {
            return
        }

        addTaskVC.itemKind = .subtask

        addTaskVC.onSave = { [weak self] name, dueDate, needToNotify in
            guard let self else {
                return
            }

            let subtask = TodoSubtask(
                name: name,
                dueDate: dueDate,
                needToNotify: needToNotify
            )

            try persistenceService.addSubtask(
                subtask,
                to: task
            )

            if needToNotify {
                sendNotification(for: subtask)
            }

            loadSubtasks()
        }
    }

}
