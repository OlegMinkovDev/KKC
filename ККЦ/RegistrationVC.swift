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
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var sexTextField: UITextField!
    
    @IBOutlet weak var complianceActiveLabel: ActiveLabel!
    @IBOutlet weak var complianceSwitch: UISwitch!
    @IBOutlet weak var registrationButton: UIButton!
    
    var pickerView = UIPickerView()
    var pickerData = [String]()
    let screenSize = UIScreen.main.bounds.size
    var activeField: UITextField?
    var pickerSelectedIndex = Int()
    var offsetY:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = createPickerAndAccessoryView()
        pickerView = picker.pickerView
        
        cityTextField.inputView = picker.pickerView
        cityTextField.inputAccessoryView = picker.accessoryView
        sexTextField.inputView = picker.pickerView
        sexTextField.inputAccessoryView = picker.accessoryView
        
        registrationButton.isEnabled = false
        
        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        screenSingleTap.delegate = self
        view.addGestureRecognizer(screenSingleTap)
        
        complianceSwitch.addTarget(self, action: #selector(complianceValueChange), for: .valueChanged)
        
        setPlaceholderColorForAllTextFields()
        setupComplianceActiveLabel()
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: - UI Methods
    @IBAction func registration(_ sender: Any) {
        
        var errorText = ""
        
        var parameters = [String: Any]()
        
        if surnameTextField.text == nil || surnameTextField.text == "" {
            
            errorText += "Поле прізвище має бути заповнено \n"
            setRedBorder(for: surnameTextField)
        }
        if nameTextField.text == nil || nameTextField.text == "" {
            
            errorText += "Поле ім'я повинно бути заповнене \n"
            setRedBorder(for: nameTextField)
        }
        if emailTextField.text == nil || emailTextField.text == "" {
            
            errorText += "Поле email має бути заповнено \n"
            setRedBorder(for: emailTextField)
        }
        if cityTextField.text == nil || cityTextField.text == "" {
            
            errorText += "Поле місто має бути заповнено \n"
            setRedBorder(for: cityTextField)
        }
        if passwordTextField.text == nil || (passwordTextField.text?.characters.count)! < 6 {
            
            errorText += "Пароль повинен бути не менше 6 символів \n"
            setRedBorder(for: passwordTextField)
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
        if passwordTextField.text != passwordAgainTextField.text {
            
            errorText += "Паролі не співпадають \n"
            setRedBorder(for: passwordAgainTextField)
        }
        
        guard errorText == "" else {
            showAlert(withTitle: "Помилка", message: errorText)
            return
        }
        
        let cityId = SettingManager.shered.getCity(byName: cityTextField.text!)?.id!
        parameters["cityid"] = cityId
        SettingManager.shered.saveCityId(cityId: cityId!)
        
        parameters["surname"] = surnameTextField.text!
        parameters["name"] = nameTextField.text!
        parameters["Email"] = emailTextField.text!
        parameters["Password"] = passwordTextField.text!
        
        NetworkManager.shared.signUp(withParameters: parameters) { (response, error) in
            
            guard error == nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                self.showAlert(withTitle: "Помилка", message: response!["message"] as! String)
                return
            }
            
            self.showAlert(withTitle: "Підтвердження", message: "Вам на пошту відправлено повідомлення для підтвердження реєстрації. Посилання дійсно протягом 30 хвилин", handler: { _ in
                
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
        
        if self.complianceSwitch.isOn {
            
            self.registrationButton.isEnabled = true
            self.registrationButton.alpha = 1
        
        } else {
            
            self.registrationButton.isEnabled = false
            self.registrationButton.alpha = 0.7
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
        
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0, right: 0.0)
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
        pickerSelectedIndex = row
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
        removeRedBorder(for: textField)
        
        if textField == cityTextField {
            
            let cities = SettingManager.shered.getCities()
            setAndReloadPickerData(data: cities)
            
        } else {
            setAndReloadPickerData(data: ["Чоловіча", "Жіноча"])
        }
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
    func createPickerAndAccessoryView() -> (pickerView: UIPickerView, accessoryView: UIView) {
        
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
        
        hideKeybourd()
        pickerSelectedIndex = 0
    }
    
    @objc func selectButtonAction() {
        
        if activeField == cityTextField {
            cityTextField.text = pickerData[pickerSelectedIndex]
        } else {
            sexTextField.text = pickerData[pickerSelectedIndex]
            sexTextField.resignFirstResponder()
        }
        
        hideKeybourd()
    }
    
    func hideKeybourd() {
        
        cityTextField.resignFirstResponder()
        sexTextField.resignFirstResponder()
        
        pickerSelectedIndex = 0
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
            sexTextField,
            cityTextField
        ]
        
        for textField in textFields {
            
            if let placeholder = textField?.placeholder {
                
                textField?.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                      attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
            }
        }
    }
    
    func setAndReloadPickerData(data: [Any]) {
        
        pickerData = []
        
        if data is [City] {
            
            for city in data as! [City] {
                pickerData.append(city.name!)
            }
            
        } else if data is [String] {
            
            for gender in data as! [String] {
                pickerData.append(gender)
            }
        }
        
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
    
    func setRedBorder(for textField: UITextField) {
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    func removeRedBorder(for textField: UITextField) {
        
        textField.layer.borderWidth = 0
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
