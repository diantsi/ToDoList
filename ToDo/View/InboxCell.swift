//
//  InboxCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 20.10.2026.
//

import UIKit

class InboxCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var receivedAtLabel: UILabel!

    func configure(with notification: NotificationTask) {
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
        receivedAtLabel.text = notification.receivedAt.formatted(
            date: .numeric,
            time: .shortened
        )
        contentView.backgroundColor = backgroundColor(
            for: notification.status
        )
    }

    private func backgroundColor(
        for status: NotificationStatus
    ) -> UIColor {
        switch status {
        case .accepted:
            return UIColor.systemGreen.withAlphaComponent(0.25)
        case .declined:
            return UIColor.systemRed.withAlphaComponent(0.25)
        case .pending:
            return .systemBackground
        }
    }

}
