//
//  ViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 07.10.2026.
//

import UIKit

class ViewController: UITableViewController {

    var persistanceService: any PersistenceService!
    private var tasks: [TodoTask] = []

    private var mytasks = [
        "Зробити лабораторну",
        "Прочитати документацію Core Data",
    ]

    override func viewDidLoad() {
        persistanceService = CoreDataService()

        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
    }

    private func loadTasks() {
        do {
            tasks = try persistanceService.fetchTasks()
            tableView.reloadData()
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }

    @IBAction func addTaskTapped(_ sender: UIBarButtonItem) {
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tasks.count
    }

    override func tableView(
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

        return cell
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
            try persistanceService.deleteTask(task)

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

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        guard segue.identifier == "ShowAddTask",
            let navigationController =
                segue.destination as? UINavigationController,
            let addTaskVC =
                navigationController.topViewController as? AddTaskViewController
        else {
            return
        }

        addTaskVC.persistenceService = persistanceService

        addTaskVC.onTaskAdded = { [weak self] in
            self?.loadTasks()
        }
    }
}
