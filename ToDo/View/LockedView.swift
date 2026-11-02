//
//  LockedView.swift
//  ToDo
//

import UIKit

final class LockedView: UIView {

    var onUnlock: (() -> Void)?

    private var imageWidthConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!

    private let imageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(systemName: "lock.fill")
        )
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Захищені завдання заблоковані"
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityLabel = "Захищені завдання заблоковані"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var unlockButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Розблокувати"
        configuration.baseBackgroundColor = UIColor(named: "AccentColor")
        configuration.baseForegroundColor = UIColor(named: "AccentForeground")
        button.configuration = configuration
        button.accessibilityLabel = "Показати захищені завдання"
        button.accessibilityHint = "Виконує біометричну перевірку"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(unlockButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            messageLabel,
            unlockButton,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .systemBackground

        addSubview(contentStackView)

        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 40)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 40)

        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(
                equalTo: layoutMarginsGuide.centerXAnchor
            ),
            contentStackView.centerYAnchor.constraint(
                equalTo: layoutMarginsGuide.centerYAnchor
            ),
            contentStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor
            ),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor
            ),
            contentStackView.topAnchor.constraint(
                greaterThanOrEqualTo: layoutMarginsGuide.topAnchor
            ),
            contentStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor
            ),
            unlockButton.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 44
            ),
            unlockButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 44
            ),
            imageWidthConstraint,
            imageHeightConstraint,
        ])

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]) {
                (self: Self, _: UITraitCollection) in
                self.updateDynamicTypeLayout()
            }
        updateDynamicTypeLayout()
    }

    private func updateDynamicTypeLayout() {
        let metrics = UIFontMetrics(forTextStyle: .body)

        imageWidthConstraint.constant = metrics.scaledValue(for: 40)
        imageHeightConstraint.constant = metrics.scaledValue(for: 40)
        contentStackView.spacing = metrics.scaledValue(for: 17)

        let inset = metrics.scaledValue(for: 0)
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: inset,
            leading: inset,
            bottom: inset,
            trailing: inset
        )
    }

    @objc private func unlockButtonTapped() {
        onUnlock?()
    }
}
