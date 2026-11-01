//
//  LoadingViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 01.11.2026.
//

import UIKit

final class LoadingViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(systemName: "figure.cooldown")
        )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isAccessibilityElement = false
        return imageView
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "я завантажуюсь"
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isAccessibilityElement = true
        label.accessibilityLabel = "триває аутентифікація"
        return label
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
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            progressLabel,
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 100),
            stackView.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
        ])
    }
}
