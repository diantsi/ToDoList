//
//  AppCoordinator.swift
//  ToDo
//
//  Created by Діана Цісарук on 24.10.2026.
//
import Foundation
import UIKit

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let storyboard: UIStoryboard

    private let credentialsRepository: CredentialsRepository

    private let authService: AuthService

    private var pendingURL: URL?

    init(window: UIWindow) {
        self.window = window
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        credentialsRepository = CredentialsRepository()
        authService = AuthService()
    }

    func start() {
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains(
                "-UITestShowAuthentication"
            ) {
                showLogin()
                return
            }

            if ProcessInfo.processInfo.arguments.contains(
                "-UITestSkipAuthentication"
            ) {
                showMainInterface()
                return
            }
        #endif

        showLoading()
        Task {
            await attemptAutomaticLogin()
        }
    }

    func registerUrl(initialUrl: URL) {
        pendingURL = initialUrl
    }

    func openURL(url: URL) {
        guard let id = decodeIdFromUrl(url),
            let tabBarController = window.rootViewController
                as? UITabBarController,
            let navigationController = tabBarController.viewControllers?.first
                as? UINavigationController,
            let task = try? PersistenceServiceProvider.shared.getTaskById(
                id: id
            ),
            let subtaskListViewController = makeTaskDetailController(task: task)
        else {
            return
        }
        tabBarController.selectedIndex = 0

        navigationController.popToRootViewController(animated: false)
        navigationController.pushViewController(
            subtaskListViewController,
            animated: true
        )

    }

    private func decodeIdFromUrl(_ url: URL) -> UUID? {
        guard url.scheme == "todo",
            url.host == "task",
            let idString = url.pathComponents.dropFirst().first,
            let id = UUID(uuidString: idString)
        else {
            return nil
        }

        return id

    }

    func makeTaskDetailController(task: TodoTask) -> SubtaskListViewController?
    {
        guard
            let controller = storyboard.instantiateViewController(
                withIdentifier: "SubtaskListViewController"
            ) as? SubtaskListViewController
        else {
            return nil
        }

        controller.persistenceService = PersistenceServiceProvider.shared
        controller.task = task

        return controller
    }

    func showLoading() {
        let controller = LoadingViewController()

        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    func showLogin() {
        guard
            let controller = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController
        else {
            return
        }

        controller.onAuthorize = { [weak self] username, password in
            Task {
                await self?.authorize(username, password)
            }
        }

        window.rootViewController = controller
    }

    func showMainInterface() {
        let controller = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        )

        window.rootViewController = controller
        if let url = pendingURL {
            pendingURL = nil
            openURL(url: url)
        }
    }

    private func authorize(_ username: String, _ password: String) async {
        let credentials = Credentials(username: username, password: password)
        do {
            try await authService.postCredentials(credentials: credentials)
            try credentialsRepository.saveCredentials(credentials: credentials)
            showMainInterface()
        } catch AuthError.invalidCredentials {
            showError(AuthError.invalidCredentials)
        } catch AuthError.serverUnavailable {
            showError(AuthError.serverUnavailable) { [weak self] in
                await self?.authorize(username, password)
            }
        } catch {
            showError(error) { [weak self] in
                await self?.authorize(username, password)
            }
        }
    }

    private func attemptAutomaticLogin() async {
        do {
            let credentials = try credentialsRepository.readCredentials()
            try await authService.postCredentials(credentials: credentials)
            print("credentials available")
            showMainInterface()
        } catch KeychainError.noData {
            showLogin()
        } catch AuthError.invalidCredentials {
            showLogin()
        } catch is CancellationError {
        } catch {
            showError(error) { [weak self] in
                await self?.attemptAutomaticLogin()
            }
        }

    }

    private func showError(
        _ error: Error,
        onRetry: (() async -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: "Не вдалося авторизуватися",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        if let onRetry {
            alert.addAction(
                UIAlertAction(
                    title: "Спробувати ще раз",
                    style: .default
                ) { _ in
                    Task {
                        await onRetry()
                    }
                }
            )

            alert.addAction(
                UIAlertAction(
                    title: "Скасувати",
                    style: .cancel
                )
            )
        } else {
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )
        }

        window.rootViewController?.present(
            alert,
            animated: true
        )
    }
}
