//
//  MyProfileVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 04/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit
import ActiveLabel

class MyProfileVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var houseTextField: UITextField!
    @IBOutlet weak var flatTextField: UITextField!
    @IBOutlet weak var socialStatusTextField: UITextField!
    @IBOutlet weak var changeEmailTextField: UITextField!
    
    @IBOutlet weak var complianceActiveLabel: ActiveLabel!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordAgainTextField: UITextField!
    @IBOutlet weak var changeEmailButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    var pickerView = UIPickerView()
    var pickerSelectedIndex = Int()
    var activeField: UITextField?
    let credintial = SettingManager.shered.getCredential()
    
    var pickerData = [String]()
    let screenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = createPickerAndAccessoryView()
        pickerView = picker.pickerView
        
        cityTextField.inputView = picker.pickerView
        cityTextField.inputAccessoryView = picker.accessoryView
        districtTextField.inputView = picker.pickerView
        districtTextField.inputAccessoryView = picker.accessoryView
        streetTextField.inputView = picker.pickerView
        streetTextField.inputAccessoryView = picker.accessoryView
        socialStatusTextField.inputView = picker.pickerView
        socialStatusTextField.inputAccessoryView = picker.accessoryView
        
        emailTextField.isEnabled = false
        
        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        screenSingleTap.delegate = self
        view.addGestureRecognizer(screenSingleTap)
        
        navigationItem.backBarButtonItem?.title = ""
        
        getMyProfile()
        setPlaceholderColorForAllTextFields()
        setupComplianceActiveLabel()
        registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentOffset = CGPoint(x: 0, y: 64)
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Мій профіль"
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: - UI Methods
    @IBAction func updateProfile(_ sender: Any) {
        
        var parameters = [String: Any]()
        
        guard let surname = surnameTextField.text, surname != "" else {
            showAlert(withTitle: "Помилка", message: "Поле прізвище має бути заповнено")
            return
        }
        guard let name = nameTextField.text, name != "" else {
            showAlert(withTitle: "Помилка", message: "Поле ім'я повинно бути заповнене")
            return
        }
        if let phone = phoneTextField.text, phone != "" {
            parameters["tel"] = phone
        }
        if let city = cityTextField.text, city != "" {
            
            let cityId = SettingManager.shered.getCity(byName: city)?.id!
            parameters["city"] = cityId
        }
        if let street = streetTextField.text, street != "" {
            
            let streetId = SettingManager.shered.getStreet(by: street)?.id!
            parameters["street"] = streetId
        }
        if let house = houseTextField.text, house != "" {
            parameters["house"] = house
        }
        if let flat = flatTextField.text, flat != "" {
            parameters["flat"] = flat
        }
        if let clientCategory = socialStatusTextField.text, clientCategory != "" {
            
            let clientCategoryId = SettingManager.shered.getClientCategory(by: clientCategory)?.id!
            parameters["category_id"] = clientCategoryId
        }
        
        parameters["name"] = name
        parameters["surname"] = surname
        
        let stringToConvert = "\(credintial!.token!):"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credintial!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
            
            NetworkManager.shared.updateMyProfile(withParameters: parameters, headers: headers) { (response, error) in
                
                guard error == nil else {
                    ErrorManager.shered.handleAnError(error: error!, viewController: self)
                    return
                }
                
                self.showAlert(withTitle: "Повідомлення", message: "Дані успішно змінені")
            }
        }
    }
    
    @IBAction func changeEmail(_ sender: UIButton) {
        
        guard let newEmail = changeEmailTextField.text, newEmail != "" else {
            showAlert(withTitle: "Помилка", message: "Введiть новий email")
            return
        }
        
        let parameters: [String : Any] = [
            "email" : newEmail
        ]
        
        NetworkManager.shared.changeEmail(withParameters: parameters, headers: SettingManager.HEADERS, completion: { (response, error) in
            
            guard error == nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                
                if error == NetworkError.invalidParameters {
                    self.showAlert(withTitle: "Помилка", message: "Невiрний email")
                } else if error == NetworkError.elementNotFound {
                    self.showAlert(withTitle: "Помилка", message: "Такий email вже iснує")
                }
                
                return
            }
            
            self.showAlert(withTitle: "Повідомлення", message: "На цей email відправлено повідомлення для підтвердженням адреси. Повідомлення дійсно 24 години", handler: { (_) in
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        })
    }
    
    @IBAction func changePassword(_ sender: Any) {
        
        guard let password = newPasswordTextField.text, password != "" else {
            showAlert(withTitle: "Помилка", message: "Поле пароль не може бути порожнім")
            return
        }
        
        guard let passwordAgain = newPasswordAgainTextField.text, password == passwordAgain else {
            showAlert(withTitle: "Помилка", message: "Паролі не співпадають")
            return
        }
        
        let parameters:[String: Any] = [
            "newpassword" : password
        ]
        
        let stringToConvert = "\(credintial!.token!):"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credintial!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
        
            NetworkManager.shared.changePassword(withParameters: parameters, headers: headers, completion: { (response, error) in
                
                guard error == nil else {
                    ErrorManager.shered.handleAnError(error: error!, viewController: self)
                    return
                }
                
                let credential = Credentials(parameters: response!)
                SettingManager.shered.saveCredential(credential: credential)
                
                self.showAlert(withTitle: "Повідомлення", message: "Пароль успішно змінений", handler: { (_) in
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            })
        }
    }
    
    @objc func screenTapAction() {
        view.endEditing(true)
    }
    
    @objc func goToMainVC() {
        
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVCID") as! UINavigationController
        
        DispatchQueue.main.async {
            self.present(mainVC, animated: true, completion: nil)
        }
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
        
        if textField == cityTextField {
            
            let cities = SettingManager.shered.getCities()
            setAndReloadPickerData(data: cities)
            
        } else if textField == districtTextField {
            
            let districts = SettingManager.shered.getDistricts()
            setAndReloadPickerData(data: districts)
        
        } else if textField == streetTextField {
            
            var streets: [Street]?
            if let text = districtTextField.text, text != "" {
                
                let district = SettingManager.shered.getDistrict(by: text)
                streets = SettingManager.shered.getStreets(by: (district?.id!)!)
           
            } else { streets = SettingManager.shered.getStreets() }
            
            setAndReloadPickerData(data: streets!)
        
        } else if textField == socialStatusTextField {
            
            let clientCategories = SettingManager.shered.getClientCategories()
            setAndReloadPickerData(data: clientCategories)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeField = nil
        
        if changeEmailTextField.text != "" {
            changeEmailButton.isEnabled = true
        } else { changeEmailButton.isEnabled = false }
        
        if newPasswordTextField.text != "" && newPasswordAgainTextField.text != "" {
            changePasswordButton.isEnabled = true
        } else { changePasswordButton.isEnabled = false }
    }
    
    // MARK: - GestureRecognize Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if ((touch.view == complianceActiveLabel)) {
            return false
        }
        return true
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
        if textField == houseTextField || textField == flatTextField {
            
            let allowLetters = CharacterSet.letters
            let allowDigits = CharacterSet.decimalDigits
            let allowSymbol = CharacterSet(charactersIn: " -").inverted
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
    }
    
    @objc func selectButtonAction() {
        
        if activeField == cityTextField {
            cityTextField.text = pickerData[pickerSelectedIndex]
            districtTextField.text = ""
            streetTextField.text = ""
        } else if activeField == districtTextField {
            districtTextField.text = pickerData[pickerSelectedIndex]
            streetTextField.text = ""
        } else if activeField == streetTextField {
            streetTextField.text = pickerData[pickerSelectedIndex]
        } else if activeField == socialStatusTextField {
            socialStatusTextField.text = pickerData[pickerSelectedIndex]
        }
        
        hideKeybourd()
    }
    
    func getMyProfile() {
        
        NetworkManager.shared.getMyProfile(withHeaders: SettingManager.HEADERS, completion: { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                return
            }
            
            let myProfile = Profile(parameters: response!)
            self.setData(profile: myProfile)
        })
    }
    
    func setData(profile: Profile) {
        
        DispatchQueue.main.async {
        
            self.emailTextField.text = profile.email
            self.phoneTextField.text = profile.tel
            self.surnameTextField.text = profile.surname
            self.nameTextField.text = profile.name
            self.houseTextField.text = profile.house
            self.flatTextField.text = profile.flat
            
            if let cityId = profile.city {
                
                let city = SettingManager.shered.getCity(byId: cityId)
                self.cityTextField.text = city?.name
            }
            
            if let streetId = profile.street {
                
                let street = SettingManager.shered.getStreet(by: streetId)
                
                self.streetTextField.text = street?.name
                self.districtTextField.text = street?.districtionName
            }
            
            if let clientCategoryId = profile.categoryId {
                
                let clientCategory = SettingManager.shered.getClientCategory(by: clientCategoryId)
                self.socialStatusTextField.text = clientCategory?.name
            }
        }
    }
    
    func setPlaceholderColorForAllTextFields() {
        
        let textFields = [
            surnameTextField,
            nameTextField,
            emailTextField,
            phoneTextField,
            districtTextField,
            streetTextField,
            houseTextField,
            flatTextField,
            socialStatusTextField,
            newPasswordTextField,
            newPasswordAgainTextField,
            cityTextField
        ]
        
        for textField in textFields {
            
            if let placeholder = textField?.placeholder {
                
                textField?.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                      attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
            }
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
    
    func setAndReloadPickerData(data: [Any]) {
        
        pickerData = []
        
        if data is [City] {
            
            for city in data as! [City] {
                pickerData.append(city.name!)
            }
            
        } else if data is [District] {
            
            for district in data as! [District] {
                pickerData.append(district.name!)
            }
        
        } else if data is [Street] {
            
            for street in data as! [Street] {
                pickerData.append(street.name!)
            }
        
        } else if data is [ClientCategory] {
            
            for clientCategory in data as! [ClientCategory] {
                pickerData.append(clientCategory.name!)
            }
        }
        
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
    
    func hideKeybourd() {
        
        cityTextField.resignFirstResponder()
        districtTextField.resignFirstResponder()
        streetTextField.resignFirstResponder()
        socialStatusTextField.resignFirstResponder()
        
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
