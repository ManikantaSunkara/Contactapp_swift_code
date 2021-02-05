//
//  ViewControllerExtensions.swift
//  ContactApp
//
//  Created by Aabid Khan on 02/12/20.
//  Copyright © 2020 Aabid Khan. All rights reserved.
//

import UIKit

extension UIViewController {
    
    struct AlertActionDetails {
        var title: String?
        var style: UIAlertAction.Style?
    }
    
    func popupAlert(title: String?, message: String?, actionDetails:[AlertActionDetails?], actions:[((UIAlertAction) -> Void)?],preferredStyle:UIAlertController.Style = .alert ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for (index, actionDetail) in actionDetails.enumerated() {
            let action = UIAlertAction(title: actionDetail?.title ?? "", style: actionDetail?.style ?? .default, handler: actions[index])
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAppName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String ?? "-"
    }
    
    private func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
}

