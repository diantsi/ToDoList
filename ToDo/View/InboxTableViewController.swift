//
//  InboxTableViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 20.10.2026.
//

import UIKit

class InboxTableViewController: UITableViewController {

    private var notifications: [NotificationTask] = []
    private let persistenceService: any PersistenceService =
        PersistenceServiceProvider.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationTasksDidChange),
            name: .notificationTasksDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
    }

    @objc private func notificationTasksDidChange() {
        loadTasks()
    }

    private func loadTasks() {
        do {
            notifications = try persistenceService.getAllNotificationTasks()
            tableView.reloadData()
        } catch {
            print("Failed to fetch push notifications: \(error.localizedDescription)")
        }
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return notifications.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "inbox_cell",
                for: indexPath
            ) as? InboxCell
        else {
            return UITableViewCell()
        }

        let notification = notifications[indexPath.row]
        cell.configure(with: notification)

        return cell
    }
}
