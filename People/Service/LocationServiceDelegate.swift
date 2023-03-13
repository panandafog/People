//
//  LocationServiceDelegate.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

import UIKit

protocol LocationServiceDelegate: AnyObject {
    func openLocationSettings()
}

extension LocationServiceDelegate where Self: UIViewController {
    func openLocationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl)
        else {
            return
        }
        
        let alertController = UIAlertController(
            title: "alert.location.openSettings.title".localized,
            message: "alert.location.openSettings.message".localized,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "alert.open".localized, style: .default) { _ in
            UIApplication.shared.open(settingsUrl)
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "alert.cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
