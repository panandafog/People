//
//  PeopleCoordinator.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import UIKit

class PeopleCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = PeopleViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
