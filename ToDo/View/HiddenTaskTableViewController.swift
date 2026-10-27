//
//  HiddenTaskTableViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 25.10.2026.
//

import UIKit

class HiddenTaskTableViewController : UITableViewController {
    
    var hiddenTasks : [TodoTask] = []
    
    let todoRepository = HiddenTaskRepository()

    private let notificationService = UserNotificationsService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tryToUnlock()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hiddenTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "hidden_cell", for: indexPath) as? HiddenCell else {
            return UITableViewCell()
        }
        let hiddenTask = hiddenTasks[indexPath.row]
        cell.configure(with: hiddenTask)

        cell.onToggle = { [weak self] in
            self?.toggleTask(id: hiddenTask.id)
        }

        return cell
    }

    private func toggleTask(id: UUID) {
        do {
            try todoRepository.toggleTodoDone(id: id)

            guard let index = hiddenTasks.firstIndex(where: { $0.id == id })
            else {
                return
            }

            hiddenTasks[index].isDone.toggle()
            tableView.reloadRows(
                at: [IndexPath(row: index, section: 0)],
                with: .automatic
            )
        } catch {
            showError(
                error,
                title: "Не вдалося оновити завдання"
            )
        }
    }
    
    private func tryToUnlock(){
        Task {
            do {
                hiddenTasks = try await todoRepository.readTodos()
                tableView.reloadData()
            } catch {
                showError(error, title: "Немає доступу")
            }
        }
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        let task = hiddenTasks[indexPath.row]

        do {
            try todoRepository.deleteTodo(for: task)
            hiddenTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            showError(error, title: "Не вдалося видалити")
        }
    }
    
    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        guard segue.identifier == "ShowAddHidden",
            let navigationController =
                segue.destination as? UINavigationController,
            let addTaskVC =
                navigationController.topViewController as? AddTaskViewController
        else {
            return
        }

        addTaskVC.isSubtask = true

        addTaskVC.onSave = { [weak self] name, dueDate, needToNotify in
            guard let self else {
                return
            }

            let task = TodoTask(
                name: name,
                dueDate: dueDate,
                needToNotify: needToNotify
            )
                        
            saveTask(task: task)

        }
    }
    
    private func saveTask(task: TodoTask){
        Task {
            do {
                try await todoRepository.saveTodo(todo: task)
            } catch {
                showError(error, title: "Не вдалося зберегти")
            }
            
            
            tryToUnlock()
        }
    }
    
    private func showError(_ error: Error, title: String) {
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
}
