import Foundation
import UIKit

class ErrorManager {
    
    static let shered = ErrorManager()
    
    func handleAnError(error: NetworkError?, viewController: UIViewController) {
        
        if error == NetworkError.tokenExpired {
            print(String(describing: viewController.self), ": token expired")
            goToAuthorizationVC(viewController)
        } else if error == NetworkError.authenticationFailed {
            print(String(describing: viewController.self), ": authentication failed")
            showAlert(viewController, withTitle: "Помилка", message: "Неправильний пароль")
        } else if error == NetworkError.elementNotFound {
            print(String(describing: viewController.self), ": element not found")
        } else if error == NetworkError.headerNotProvided {
            print(String(describing: viewController.self), ": header not provided")
        } else if error == NetworkError.headerValueError {
            print(String(describing: viewController.self), ": header value error")
        } else if error == NetworkError.invalidParameters {
            print(String(describing: viewController.self), ": invalid parameters")
        } else if error == NetworkError.notResourceOwner {
            print(String(describing: viewController.self), ": not resource owner")
        } else if error == NetworkError.operationFailed {
            print(String(describing: viewController.self), ": operation failed")
        } else if error == nil {
            print(String(describing: viewController.self), ": response = nil")
        }
    }
    
    private func goToAuthorizationVC(_ viewController: UIViewController) {
        
        let authorizationVC = viewController.storyboard?.instantiateViewController(withIdentifier: "AuthorizationVCID") as! AuthorizationVC
        
        DispatchQueue.main.async {
            viewController.present(authorizationVC, animated: false, completion: nil)
        }
    }
    
    private func showAlert(_ viewController: UIViewController, withTitle: String, message: String) {
        
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
