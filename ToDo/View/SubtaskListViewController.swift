//
//  SubtaskListViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//

import UIKit

class SubtaskListViewController: UITableViewController {

    var persistenceService: any PersistenceService!
    var task: TodoTask!
    private var subtasks: [TodoSubtask] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = task.name
        loadSubtasks()
    }
    
    private func loadSubtasks() {
        do {
            subtasks = try persistenceService.getSubtasks(
                for: task.id
            )

            tableView.reloadData()
        } catch {
            print("Failed to fetch subtasks: \(error.localizedDescription)")
        }
    }


    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return subtasks.count
    }

    override func tableView(
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

        return cell
    }

    private func toggleSubtask(id: UUID) {
        guard
            let index = subtasks.firstIndex(
                where: { $0.id == id }
            )
        else {
            return
        }
        let subtask = subtasks[index]
        
        do {
            try persistenceService.toggleSubtaskDone(subtask)
            loadSubtasks()
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

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        let subtask = subtasks[indexPath.row]

        do {
            try persistenceService.deleteSubtask(subtask)

            subtasks.remove(at: indexPath.row)
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

        addTaskVC.isSubtask = true

        addTaskVC.onSave = { [weak self] name, _ in
            guard let self else {
                return
            }

            let subtask = TodoSubtask(name: name)

            try persistenceService.addSubtask(
                subtask,
                to: task
            )

            loadSubtasks()
        }
    }

}
