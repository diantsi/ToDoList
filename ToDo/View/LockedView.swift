//
//  LockedView.swift
//  ToDo
//

import UIKit

final class LockedView: UIView {

    var onUnlock: (() -> Void)?

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

        addSubview(imageView)
        addSubview(messageLabel)
        addSubview(unlockButton)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(
                equalTo: centerYAnchor,
                constant: -50
            ),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),

            messageLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: 12
            ),
            messageLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 24
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -24
            ),

            unlockButton.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: 20
            ),
            unlockButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    @objc private func unlockButtonTapped() {
        onUnlock?()
    }
}
