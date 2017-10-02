//
//  AuthorizationVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 31/07/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class AuthorizationVC: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    
    let screenSize = UIScreen.main.bounds.size
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.attributedPlaceholder = NSAttributedString(string: "Введіть e-mail",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Введіть пароль",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        emailTextField.tintColor = .white
        passwordTextField.tintColor = .white
        
        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide))
        view.addGestureRecognizer(screenSingleTap)
        
        getCities()
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: UI Methods
    @IBAction func goToMainVC(_ button: UIButton) {
        
        guard let login = emailTextField.text, login != "" else {
            showAlert(withTitle: "Помилка", message: "Логін або пароль не можуть бути порожніми")
            return
        }
        guard let password = passwordTextField.text, password != "" else {
            showAlert(withTitle: "Помилка", message: "Логін або пароль не можуть бути порожніми")
            return
        }
        
        let stringToConvert = "\(login):\(password)"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            let headers = ["Authorization" : base64String]
            
            NetworkManager.shared.verifyCredentials(headers: headers, completion: { (response, error) in
                
                guard error == nil else {
                    ErrorManager.shered.handleAnError(error: error!, viewController: self)
                    return
                }
                
                let credential = Credentials(parameters: response!)
                SettingManager.shered.saveCredential(credential: credential)
                
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVCID") as! UINavigationController
                
                DispatchQueue.main.async {
                    self.present(mainVC, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func goToRegistration(_ button: UIButton) {
        performSegue(withIdentifier: "toRegistrationVC", sender: self)
    }
    
    // MARK: NotificationCenter & Keybourd Events
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func removeKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        //Need to calculate keyboard exact size due to Apple suggestions
        guard let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        scrollView.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        scrollView.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0, right: 0.0)
        scrollView.isScrollEnabled = true
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        scrollView.isScrollEnabled = false
    }
    
    // MARK: - TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
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
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    // MARK: - Heplful functions
    func showAlert(withTitle: String, message: String) {
        
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getCities() {
        
        let parameters: [String: Any] = [
            "culture" : "ua",
            "cityid" : 0
        ]
        
        NetworkManager.shared.getCities(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let listCities = response!["list"] as! [NSDictionary]
            
            listCities.forEach({ (dictionary) in
                
                let city = City(dictionary: dictionary)
                
                if city.name == "Мариуполь" {
                    
                    let mariupolId = city.id!
                    SettingManager.shered.saveCityId(cityId: mariupolId)
                }
            })
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
