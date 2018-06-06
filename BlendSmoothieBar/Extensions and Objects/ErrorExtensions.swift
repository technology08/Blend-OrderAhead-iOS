//
//  ErrorExtensions.swift
//  BlendSmoothieBar
//
//  Created by Connor Espenshade on 6/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import UIKit
import CloudKit

// MARK: - Error Alert Extensions

extension Error {
    func alert() -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: self.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        return alert
    }
}

extension CKError {
    func handleAndAlert(crash: Bool = false) -> UIAlertController {
        var title: String = "Error"
        var message: String = self.localizedDescription
        
        if self.code == CKError.Code.notAuthenticated {
            title = "Not Authenticated"
            message = "You are not signed into iCloud Drive. Please go to Settings, enable iCloud, enable iCloud Drive, and turn on 'Blend' in the list of apps."
        } else if self.code == CKError.Code.networkUnavailable || self.code == CKError.Code.networkFailure {
            title = "Lost Connection"
            message = "Please connect to the internet to proceed."
        } else if self.code == CKError.Code.incompatibleVersion {
            title = "Update Required"
            message = "This app version is outdated. Please update the app to proceed."
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if crash {
                fatalError()
            }
        }))
        return alert
    }
}
