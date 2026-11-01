//
//  AddTaskViewController.swift
//  ToDo
//
//  Created by Діана Цісарук on 13.10.2026.
//
import UIKit

final class AddTaskViewController: UIViewController {

    enum ItemKind {
        case task
        case subtask
        case protectedTask

        var name: String {
            switch self {
            case .task:
                return "завдання"
            case .subtask:
                return "підзавдання"
            case .protectedTask:
                return "захищене завдання"
            }
        }

        var navigationTitle: String {
            "Додати \(name)"
        }

        var savedAnnouncement: String {
            switch self {
            case .task:
                return "Завдання збережено"
            case .subtask:
                return "Підзавдання збережено"
            case .protectedTask:
                return "Захищене завдання збережено"
            }
        }
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var toNotifySwitch: UISwitch!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var notificationStackView: UIStackView!
    @IBOutlet weak var contentStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentStackLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentStackTrailingConstraint: NSLayoutConstraint!
    
    var itemKind: ItemKind = .task

    var onSave: ((String, Date, Bool) async throws -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setLimitForDatePicker()

        navigationItem.title = itemKind.navigationTitle

        configureAccessibility()
        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (self: Self, _: UITraitCollection) in
            self.updateDynamicTypeLayout()
        }
        updateDynamicTypeLayout()
    }

    private func configureAccessibility() {
        let itemName = itemKind.name
        saveBarButton.accessibilityLabel = "зберегти \(itemName)"
        nameTextField.accessibilityLabel = "назва \(itemName)"
        
        dueDatePicker.accessibilityLabel = "Термін виконання"
        
        toNotifySwitch.accessibilityLabel =
                "Увімкнути нагадування про \(itemName)"
        
        cancelBarButton.accessibilityLabel = "Закрити вкладку"

    }

    private func updateDynamicTypeLayout() {
        let usesAccessibilityCategory = traitCollection
            .preferredContentSizeCategory.isAccessibilityCategory

        notificationStackView.axis =
            usesAccessibilityCategory ? .vertical : .horizontal
        notificationStackView.alignment =
            usesAccessibilityCategory ? .fill : .center
        toNotifySwitch.contentHorizontalAlignment =
            usesAccessibilityCategory ? .leading : .center

        let metrics = UIFontMetrics(forTextStyle: .body)
        contentStackView.spacing = metrics.scaledValue(for: 10)
        notificationStackView.spacing = metrics.scaledValue(for: 8)

        let inset = metrics.scaledValue(for: 10)
        contentStackTopConstraint.constant = inset
        contentStackLeadingConstraint.constant = inset
        contentStackTrailingConstraint.constant = inset
    }

    private func setLimitForDatePicker() {
        let calendar = Calendar.current
        let currentMinute =
            calendar.date(
                bySetting: .second,
                value: 0,
                of: Date()
            ) ?? Date()

        let minimumDate =
            calendar.date(
                byAdding: .minute,
                value: 1,
                to: currentMinute
            ) ?? Date()

        dueDatePicker.minimumDate = minimumDate
        dueDatePicker.setDate(minimumDate, animated: false)
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard
            let name = nameTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty
        else {
            UIAccessibility.post(
                notification: .announcement,
                argument: "назва не може бути порожньою"
            )
            return
        }
        let dueDate = dueDatePicker.date
        let needToNotify = toNotifySwitch.isOn
        let savedAnnouncement = itemKind.savedAnnouncement
        saveBarButton.isEnabled = false

        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            do {
                try await onSave?(name, dueDate, needToNotify)
                dismiss(animated: true) {
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: savedAnnouncement
                    )
                }
            } catch {
                saveBarButton.isEnabled = true
                showSaveError(error)
            }
        }
    }

    private func showSaveError(_ error: Error) {
        let alert = UIAlertController(
            title: "Не вдалося зберегти",
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
