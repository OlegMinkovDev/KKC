//
//  RegistrationVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 31/07/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit
import ActiveLabel

class RegistrationVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    
    @IBOutlet weak var complianceActiveLabel: ActiveLabel!
    @IBOutlet weak var complianceSwitch: UISwitch!
    @IBOutlet weak var registrationButton: UIButton!
    
    let pickerData = ["Чоловіча", "Жіноча"]
    let screenSize = UIScreen.main.bounds.size
    var activeField: UITextField?
    var sexIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = createPickerView()
        
        sexTextField.inputView = picker.inputView
        sexTextField.inputAccessoryView = picker.accessoryView
        
        registrationButton.isEnabled = false
        
        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        screenSingleTap.delegate = self
        view.addGestureRecognizer(screenSingleTap)
        
        complianceSwitch.addTarget(self, action: #selector(complianceValueChange), for: .valueChanged)
        
        getCities()
        setPlaceholderColorForAllTextFields()
        setupComplianceActiveLabel()
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: - UI Methods
    @IBAction func registration(_ sender: Any) {
        
        var parameters = [String: Any]()
        
        guard let surname = surnameTextField.text, surname != "" else {
            showAlert(withTitle: "Помилка", message: "Поле прізвище має бути заповнено")
            return
        }
        guard let name = nameTextField.text, name != "" else {
            showAlert(withTitle: "Помилка", message: "Поле ім'я повинно бути заповнене")
            return
        }
        guard let email = emailTextField.text else {
            showAlert(withTitle: "Помилка", message: "Поле email має бути заповнено")
            return
        }
        guard let password = passwordTextField.text, password.characters.count >= 6 else {
            showAlert(withTitle: "Помилка", message: "Пароль повинен бути не менше 6 символів")
            return
        }
        if let gender = sexTextField.text {
            
            if gender == "Чоловіча" {
                parameters["gender"] = 1
            } else if gender == "Жіноча" {
                parameters["gender"] = 2
            } else {
                parameters["gender"] = 0
            }
        }
        
        parameters["surname"] = surname
        parameters["name"] = name
        parameters["Email"] = email
        parameters["Password"] = password
        parameters["cityid"] = SettingManager.shered.getCityId()
        
        guard let passwordAgain = passwordAgainTextField.text, parameters["Password"] as! String == passwordAgain else {
            
            showAlert(withTitle: "Помилка", message: "Паролі не співпадають")
            return
        }
        
        NetworkManager.shared.signUp(withParameters: parameters) { (response, error) in
            
            guard error == nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                return
            }
            
            self.showAlert(withTitle: "Регистрация", message: "Ви успішно зареєстровані", handler: { _ in
                
                let credential = Credentials(parameters: response!)
                SettingManager.shered.saveCredential(credential: credential)
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func backToAuthorizationVC(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func complianceValueChange(_ sender: UISwitch) {
        
        if complianceSwitch.isOn {
            registrationButton.isEnabled = true
        } else {
            registrationButton.isEnabled = false
        }
    }
    
    @objc func screenTapAction() {
        view.endEditing(true)
    }
    
    // MARK: - NotificationCenter & Keybourd Events
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
        
        if #available(iOS 11.0, *) {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
        }
    }
    
    // MARK: - PickerView Delegate & DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sexIndex = row
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        
        if textField == surnameTextField || textField == nameTextField {
            
            let allowLetters = CharacterSet.letters
            let allowSymbol = CharacterSet(charactersIn: " -'").inverted
            let charactersSet = CharacterSet(charactersIn: string)
            
            if allowLetters.isSuperset(of: charactersSet) || string.rangeOfCharacter(from: allowSymbol) == nil {
                return true
            }
            
            return false
        }
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
    
    // MARK: - GestureRecognize Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if ((touch.view == complianceActiveLabel)) {
            return false
        }
        return true
    }

    // MARK: - Heplful functions
    func createPickerView() -> (inputView: UIView, accessoryView: UIView) {
        
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        accessoryView.backgroundColor = .groupTableViewBackground
        
        let accessoryButtonWidth:CGFloat = 100
        let accessoryButtonHeight:CGFloat = 30
        
        var okButton: UIButton {
            
            let rect = CGRect(x: screenSize.width - accessoryButtonWidth - 15, y: accessoryView.frame.height / 2 - accessoryButtonHeight / 2, width: accessoryButtonWidth, height: accessoryButtonHeight)
            
            let button = UIButton(frame: rect)
            button.setTitle("Вибрати", for: .normal)
            button.backgroundColor = UIColor(red: 39/255, green: 100/255, blue: 180/255, alpha: 1)
            button.setBackgroundImage(UIImage(named: "emptyFrameButton"), for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 7
            button.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
            
            return button
        }
        
        var cancelButton: UIButton {
            
            let rect = CGRect(x: 15, y: accessoryView.frame.height / 2 - accessoryButtonHeight / 2, width: accessoryButtonWidth, height: accessoryButtonHeight)
            
            let button = UIButton(frame: rect)
            button.setTitle("Відміна", for: .normal)
            button.backgroundColor = UIColor(red: 39/255, green: 100/255, blue: 180/255, alpha: 1)
            button.setBackgroundImage(UIImage(named: "emptyFrameButton"), for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 7
            button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
            
            return button
        }
        
        accessoryView.addSubview(okButton)
        accessoryView.addSubview(cancelButton)
        
        let separatorView = UIView(frame: CGRect(x: 0, y: accessoryView.frame.height - 1, width: screenSize.width, height: 1))
        separatorView.backgroundColor = .lightGray
        accessoryView.addSubview(separatorView)
        
        let pickerView = UIPickerView()
        pickerView.bounds.size.height = 216
        pickerView.backgroundColor = .groupTableViewBackground
        pickerView.delegate = self
        pickerView.dataSource = self
        
        return (pickerView, accessoryView)
    }
    
    @objc func cancelButtonAction() {
        sexTextField.resignFirstResponder()
    }
    
    @objc func selectButtonAction() {
        
        sexTextField.text = pickerData[sexIndex]
        sexTextField.resignFirstResponder()
    }
    
    func showAlert(withTitle: String, message: String) {
        
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlert(withTitle: String, message: String, handler: ((UIAlertAction) -> Void)?) {
        
        let alertController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            handler!(alert)
        }
    
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setupComplianceActiveLabel() {
        
        let personalDataType = ActiveType.custom(pattern: "\\sперсональних даних\\b")
        let rulesModerationTreatment = ActiveType.custom(pattern: "\\sправилами модерації звернення\\b")
        
        complianceActiveLabel.enabledTypes = [personalDataType, rulesModerationTreatment]
        
        complianceActiveLabel.customize { (label) in
            
            //Custom types
            label.customColor[personalDataType] = UIColor(red: 39/255, green: 100/255, blue: 180/255, alpha: 1)
            label.customColor[rulesModerationTreatment] = UIColor(red: 39/255, green: 100/255, blue: 180/255, alpha: 1)
            
            label.handleCustomTap(for: personalDataType, handler: { (result) in
                let vc = UIAlertController(title: "", message: "personalDataType", preferredStyle: UIAlertControllerStyle.alert)
                vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
            })
            
            label.handleCustomTap(for: rulesModerationTreatment, handler: { (result) in
                let vc = UIAlertController(title: "", message: "rulesModerationTreatment", preferredStyle: UIAlertControllerStyle.alert)
                vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    func setPlaceholderColorForAllTextFields() {
        
        let textFields = [
            surnameTextField,
            nameTextField,
            emailTextField,
            passwordTextField,
            passwordAgainTextField,
            sexTextField
        ]
        
        for textField in textFields {
            
            if let placeholder = textField?.placeholder {
                
                textField?.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                      attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
            }
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
