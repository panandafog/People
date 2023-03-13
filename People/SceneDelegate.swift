//
//  SceneDelegate.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var coordinator: PeopleCoordinator?
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let navigationController = UINavigationController()
        coordinator = PeopleCoordinator(navigationController: navigationController)
        coordinator!.start()
        
        window = UIWindow(windowScene: windowScene)
        window!.backgroundColor = .systemBackground
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
    }
}
