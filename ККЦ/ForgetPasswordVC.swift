//
//  ForgetPasswordVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 05/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class ForgetPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Введіть e-mail",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])

        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(screenSingleTap)
    }

    @IBAction func send(_ sender: Any) {
        
        guard let email = emailTextField.text, email != "" else {
            showAlert(withTitle: "Помилка", message: "Поле email не повинно бути порожнім")
            return
        }
        
        let parameters: [String: Any] = [
            "Email" : "\(email)"
        ]
        
        NetworkManager.shared.forgotPassword(withParameters: parameters) { (response, error) in
            
            guard error == nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                
                if error == .elementNotFound {
                    self.showAlert(withTitle: "Помилка", message: "Введіть email який ви вводили при реєстрації")
                } else if error == .invalidParameters {
                    self.showAlert(withTitle: "Помилка", message: "Некоректно введений email")
                }
                
                return
            }
            
            if response?["code"] as? Int == 300 {
                
                var str = response?["message"] as! String
                str = str.replacingOccurrences(of: ",", with: "")
                let strArr = str.components(separatedBy: " ")
                
                for item in strArr {
                    
                    if Int(item) != nil {
                        self.showAlert(withTitle: "", message: "Ваш пароль \(item), але поштова сисема ще не налаштована")
                    }
                }
            }
        }
    }
    
    @IBAction func backToAuthorizationVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func screenTapAction() {
        view.endEditing(true)
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        
        if textField == emailTextField {
            
            let allowLetters = CharacterSet.letters
            let allowDigits = CharacterSet.decimalDigits
            let allowSymbol = CharacterSet(charactersIn: "-_@.").inverted
            let charactersSet = CharacterSet(charactersIn: string)
            
            if allowLetters.isSuperset(of: charactersSet) || allowDigits.isSuperset(of: charactersSet) || string.rangeOfCharacter(from: allowSymbol) == nil {
                return true
            }
            
            return false
        }
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= SettingManager.MAX_TEXTFIELD_LENGTH
    }
    
    // MARK: - Helpful functions
    func showAlert(withTitle: String, message: String) {
        
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
