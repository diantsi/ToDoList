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
    let notificationService = UserNotificationsService.shared
    
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
        return cell
    }
    
    private func tryToUnlock(){
        Task {
            do {
                hiddenTasks = try await todoRepository.readTodos()
                tableView.reloadData()
            } catch {
                showError(error)
            }
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
            
            let hidden = task.hiddenTask
            
            do {
                try todoRepository.saveTodo(todo: task)
            } catch {
                showError(error)
            }
            
            if needToNotify {
                sendNotification(for: hidden)
            }
            
            tryToUnlock()

        }
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
            } catch {
                showError(error)
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Немає доступу",
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
