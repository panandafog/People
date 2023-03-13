//
//  Coordinator.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
