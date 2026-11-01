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
    @IBOutlet weak var cellStackView: UIStackView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]) {
                (self: Self, _: UITraitCollection) in
                self.updateDynamicTypeLayout()
            }
        updateDynamicTypeLayout()
    }

    func updateDynamicTypeLayout() {
        let usesAccessibilityCategory = traitCollection
            .preferredContentSizeCategory.isAccessibilityCategory

        cellStackView.axis = usesAccessibilityCategory ? .vertical : .horizontal
        cellStackView.alignment = usesAccessibilityCategory ? .fill : .center

        let metrics = UIFontMetrics(forTextStyle: .body)

        cellStackView.spacing = metrics.scaledValue(for: 12)

        let horizontalConstraint = metrics.scaledValue(for: 20)
        trailingConstraint.constant = horizontalConstraint
        leadingConstraint.constant = horizontalConstraint

        let verticalConstraint = metrics.scaledValue(for: 10)
        topConstraint.constant = verticalConstraint
        bottomConstraint.constant = verticalConstraint
    }

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
