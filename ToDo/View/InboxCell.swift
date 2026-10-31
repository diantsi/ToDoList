//
//  InboxCell.swift
//  ToDo
//
//  Created by Діана Цісарук on 20.10.2026.
//

import UIKit

final class InboxCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var receivedAtLabel: UILabel!

    func configure(with notification: NotificationTask) {
        titleLabel.text = notification.title
        bodyLabel.text = notification.body
        let receivedAt = notification.receivedAt.formatted(
            date: .numeric,
            time: .shortened
        )
        receivedAtLabel.text = receivedAt

        let presentation = presentation(
            for: notification.status
        )

        contentView.backgroundColor = presentation.color
        
        accessibilityLabel = [
            notification.title,
            notification.body,
            "Надіслано \(notification.receivedAt.voiceOverFormatted)",
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ". ")
        accessibilityValue = presentation.accessibilityValue
        accessibilityTraits = .staticText
    }
    

    private func presentation(
        for status: NotificationStatus
    ) -> (
        color: UIColor,
        accessibilityValue: String
    ) {
        switch status {
        case .accepted:
            return (
                UIColor.systemGreen.withAlphaComponent(0.25),
                "Статус: прийнято"
            )
        case .declined:
            return (
                UIColor.systemRed.withAlphaComponent(0.25),
                "Статус: відхилено"
            )
        case .pending:
            return (
                .systemBackground,
                "Статус: очікує підтвердження"
            )
        }
    }

   
}
