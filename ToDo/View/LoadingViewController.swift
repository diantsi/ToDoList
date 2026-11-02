//
//  LoadingViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 01.11.2026.
//

import UIKit

final class LoadingViewController: UIViewController {

    private var imageWidthConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!

    private let imageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(systemName: "figure.cooldown")
        )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isAccessibilityElement = false
        imageView.tintColor = UIColor(named: "AccentColor")
        return imageView
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "я завантажуюсь"
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isAccessibilityElement = true
        label.accessibilityLabel = "триває аутентифікація"
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            progressLabel,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("LoadingViewController must be created programmatically")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIAccessibility.post(
            notification: .announcement,
            argument: "перевіряємо аутентифікацію"
        )
        setupView()

        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]) {
                (self: Self, _: UITraitCollection) in
                self.updateDynamicTypeLayout()
            }
        updateDynamicTypeLayout()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(contentStackView)

        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 100)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)

        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            contentStackView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            contentStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor
            ),
            contentStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor
            ),
            contentStackView.topAnchor.constraint(
                greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor
            ),
            contentStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor
            ),
            imageWidthConstraint,
            imageHeightConstraint,
        ])
    }

    private func updateDynamicTypeLayout() {
        let metrics = UIFontMetrics(forTextStyle: .headline)

        imageWidthConstraint.constant = metrics.scaledValue(for: 100)
        imageHeightConstraint.constant = metrics.scaledValue(for: 100)
        contentStackView.spacing = metrics.scaledValue(for: 20)

        let inset = metrics.scaledValue(for: 0)
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: inset,
            leading: inset,
            bottom: inset,
            trailing: inset
        )
    }
}
