//
//  SendAppealVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 02/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit
import CoreLocation

class SendAppealVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var houseTextField: UITextField!
    @IBOutlet weak var flatTextField: UITextField!
    @IBOutlet weak var derectionAppealTextField: UITextField!
    @IBOutlet weak var eventTypeTextField: UITextField!
    @IBOutlet weak var describeProblemTextField: UITextField!
    @IBOutlet weak var appealTypeTextField: UITextField!
    
    @IBOutlet weak var extraDistrictTextField: UITextField!
    @IBOutlet weak var extraStreetTextField: UITextField!
    @IBOutlet weak var extraHouseTextField: UITextField!
    @IBOutlet weak var extraFlatTextField: UITextField!
    
    @IBOutlet weak var indicateAddressSwitch: UISwitch!
    @IBOutlet weak var placeProblemEqualAddressSwitch: UISwitch!
    @IBOutlet weak var autoIdentifyAddressSwitch: UISwitch!
    @IBOutlet weak var showOnSiteSwitch: UISwitch!
    
    @IBOutlet weak var takePhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoImageView: UIImageView!
    @IBOutlet weak var imageToSend: UIImageView!
    
    @IBOutlet weak var extraView: UIView!
    @IBOutlet weak var extraConstraint: NSLayoutConstraint!
    @IBOutlet weak var extraConstraintSwitch: NSLayoutConstraint!
    @IBOutlet weak var collectionViewConstraint: NSLayoutConstraint!
    
    var activeField: UITextField?
    var pickerView = UIPickerView()
    var imagePicker: UIImagePickerController!
    
    var photoIndex = 0
    var contact = Contact()
    var latitude:CGFloat?
    var longitude:CGFloat?
    let locationManager = CLLocationManager()
    var pickerSelectedIndex = Int()
    var pickerData = [String]()
    var collectionData = [UIImage]()
    let screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picker = createPickerAndAccessoryView()
        pickerView = picker.pickerView
        
        derectionAppealTextField.inputView = picker.pickerView
        derectionAppealTextField.inputAccessoryView = picker.accessoryView
        eventTypeTextField.inputView = picker.pickerView
        eventTypeTextField.inputAccessoryView = picker.accessoryView
        appealTypeTextField.inputView = picker.pickerView
        appealTypeTextField.inputAccessoryView = picker.accessoryView
        districtTextField.inputView = picker.pickerView
        districtTextField.inputAccessoryView = picker.accessoryView
        streetTextField.inputView = picker.pickerView
        streetTextField.inputAccessoryView = picker.accessoryView
        extraDistrictTextField.inputView = picker.pickerView
        extraDistrictTextField.inputAccessoryView = picker.accessoryView
        extraStreetTextField.inputView = picker.pickerView
        extraStreetTextField.inputAccessoryView = picker.accessoryView
        
        eventTypeTextField.isEnabled = false
        
        let takePhotoTap = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        let addPhotoTap = UITapGestureRecognizer(target: self, action: #selector(addPhoto))
        
        takePhotoImageView.isUserInteractionEnabled = true
        addPhotoImageView.isUserInteractionEnabled = true
        takePhotoImageView.addGestureRecognizer(takePhotoTap)
        addPhotoImageView.addGestureRecognizer(addPhotoTap)
        
        placeProblemEqualAddressSwitch.addTarget(self, action: #selector(showHideExtraField), for: .valueChanged)
        indicateAddressSwitch.addTarget(self, action: #selector(enableDisableAddressField), for: .valueChanged)
        autoIdentifyAddressSwitch.addTarget(self, action: #selector(identifyLocation), for: .valueChanged)
        
        extraView.isHidden = false
        extraConstraint.constant = 290
        extraConstraintSwitch.constant = 299
        
        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(screenSingleTap)
        
        setPlaceholderColorForAllTextFields()
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Надіслати звернення"
    }
    
    // MARK: - UI Methods
    @objc func takePhoto(_ sender: UITapGestureRecognizer) {
        
        if collectionData.count < 5 {
            
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            DispatchQueue.main.async {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        } else {
            showAlert(withTitle: "Помилка", message: "Максимальна кількість фото 5")
        }
    }
    
    @objc func addPhoto(_ sender: UITapGestureRecognizer) {
        
        if collectionData.count < 5 {
            
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            DispatchQueue.main.async {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        } else {
            showAlert(withTitle: "Помилка", message: "Максимальна кількість фото 5")
        }
    }
    
    @objc func showHideExtraField(_ sender: UISwitch) {
        
        if sender.isOn {
            
            self.extraView.isHidden = true
            self.extraConstraint.constant = 10
            self.extraConstraintSwitch.constant = 19
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
        } else {
            
            self.extraView.isHidden = false
            self.extraConstraint.constant = 290
            self.extraConstraintSwitch.constant = 299
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func enableDisableAddressField(_ sender: UISwitch) {
        
        if sender.isOn {
            setEnabledTextFields(isEnable: true)
        } else { setEnabledTextFields(isEnable: false) }
    }
    
    @objc func identifyLocation(_ sender: UISwitch) {
        
        if sender.isOn {
            
            // Ask for Authorisation from the User.
            self.locationManager.requestAlwaysAuthorization()
            
            // For use in foreground
            self.locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    @objc func screenTapAction() {
        view.endEditing(true)
    }
    
    @IBAction func sendAppeal(_ sender: Any) {
        
        var parameters = [String: Any]()
        
        guard let derectionAppeal = derectionAppealTextField.text, derectionAppeal != "" else {
            showAlert(withTitle: "Помилка", message: "Поле направлення звернення має бути заповнено")
            return
        }
        guard let eventType = eventTypeTextField.text, eventType != "" else {
            showAlert(withTitle: "Помилка", message: "Поле тип події має бути заповнено")
            return
        }
        guard let appealType = appealTypeTextField.text, appealType != "" else {
            showAlert(withTitle: "Помилка", message: "Поле тип звернення має бути заповнено")
            return
        }
        guard let describeProblem = describeProblemTextField.text, describeProblem != "" else {
            showAlert(withTitle: "Помилка", message: "Поле опис проблеми має бути заповнено")
            return
        }
        
        if let extraDistrict = extraDistrictTextField.text, extraDistrict != "", let extraStreet = extraStreetTextField.text, extraStreet != "", let extraHouse = extraHouseTextField.text, extraHouse != "" {
            
            let street = SettingManager.shered.getStreet(by: extraStreet)
            parameters["street_id"] = street?.id!
            parameters["house"] = extraHouse
            
        } else if let lat = latitude, let lng = longitude {
         
            parameters["lat"] = lat
            parameters["lng"] = lng
        
        } else {
            showAlert(withTitle: "Помилка", message: "Адреса проблеми повинна бути заповнена")
        }
        
        if let flat = flatTextField.text, flat != "" {
            parameters["flat"] = flat
        }
        if let describeProblem = describeProblemTextField.text, describeProblem != "" {
            parameters["note"] = describeProblem
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringFromDate = formatter.string(from: Date())
        
        parameters["date"] = stringFromDate
        
        let isPublic = (showOnSiteSwitch.isOn == true) ? "1" : "0"
        parameters["is_public"] = isPublic
        
        let problem = SettingManager.shered.getProblem(by: derectionAppeal)
        parameters["problem_id"] = problem?.id!
        
        let cause = SettingManager.shered.getCause(by: eventType)
        parameters["cause_id"] = cause?.id!
        
        let listOfTypes = SettingManager.shered.getContactType(by: appealType)
        parameters["type_id"] = listOfTypes?.id!
        
        parameters["cityid"] = SettingManager.shered.getCityId()
        
        let credintial = SettingManager.shered.getCredential()
        
        let stringToConvert = "\(credintial!.token!):"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credintial!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
            
            NetworkManager.shared.setNewContact(withParameters: parameters, headers: headers, completion: { (response, error) in
                
                guard error == nil else {
                    ErrorManager.shered.handleAnError(error: error!, viewController: self)
                    return
                }
                
                self.contact = Contact(dictionary: parameters as NSDictionary)
                
                let parentId = response!["id"] as! Int
                self.setNewImage(by: parentId, andHeaders: headers)
            })
        }
    }
    
    // MARK: - UINavigationController & UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if collectionData.count == 0 {
            collectionViewConstraint.constant = 212
            collectionView.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            collectionData.append(image)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        } else {
            print("Something went wrong")
        }
        
        DispatchQueue.main.async {
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = CGFloat(locValue.latitude)
        longitude = CGFloat(locValue.longitude)
        
        let parameters: [String : Any] = [
            "lat" : locValue.latitude,
            "lng" : locValue.longitude
        ]
        
        NetworkManager.shared.getGeoList(withParameters: parameters) { (response, error) in
            
            guard error == nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                return
            }
            
            let results = response!["results"] as! [NSDictionary]
            let address_components = results[0]["address_components"] as! [NSDictionary]
            for (index, address_component) in address_components.enumerated() {
                
                if let name = address_component["long_name"] as? String {
                    
                    DispatchQueue.main.async {
                        
                        if index == 0 {
                            self.extraHouseTextField.text = name
                        } else if index == 1 {
                            self.extraStreetTextField.text = name
                        } else if index == 2 {
                            self.extraDistrictTextField.text = name
                        }
                    }
                }
            }
        }
        
        manager.stopUpdatingLocation()
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
        scrollView.isScrollEnabled = false
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
        if textField == districtTextField || textField == extraDistrictTextField {
            
            let districts = SettingManager.shered.getDistricts()
            setAndReloadPickerData(data: districts)
            
        } else if textField == streetTextField {
            
            var streets: [Street]?
            if let text = districtTextField.text, text != "" {
                
                let district = SettingManager.shered.getDistrict(by: text)
                streets = SettingManager.shered.getStreets(by: (district?.id!)!)
                
            } else { streets = SettingManager.shered.getStreets() }
            
            setAndReloadPickerData(data: streets!)
        
        } else if textField == extraStreetTextField {
          
            var extraStreets: [Street]?
            if let text = extraDistrictTextField.text, text != "" {
                
                let extraDistrict = SettingManager.shered.getDistrict(by: text)
                extraStreets = SettingManager.shered.getStreets(by: (extraDistrict?.id!)!)
                
            } else { extraStreets = SettingManager.shered.getStreets() }
            
            setAndReloadPickerData(data: extraStreets!)
            
        } else if textField == derectionAppealTextField {
            
            let problems = SettingManager.shered.getProblems()
            setAndReloadPickerData(data: problems)
        
        } else if textField == appealTypeTextField {
            
            let contactTypes = SettingManager.shered.getContactTypes()
            setAndReloadPickerData(data: contactTypes)
        
        } else if textField == eventTypeTextField {
            
            if !textField.isEnabled {
                showAlert(withTitle: "Помилка", message: "Спочатку потрібно вибрати напрямок звернення")
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeField = nil
        
        if textField == derectionAppealTextField {
            
            if let name = textField.text, name != "" {
                
                let currentProblem = SettingManager.shered.getProblem(by: name)
                getCause(by: currentProblem!.id!)
                
                eventTypeTextField.isEnabled = true
            }
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
        
        if activeField == districtTextField {
            districtTextField.text = pickerData[pickerSelectedIndex]
            streetTextField.text = ""
        } else if activeField == streetTextField {
            streetTextField.text = pickerData[pickerSelectedIndex]
        } else if activeField == extraDistrictTextField {
            extraDistrictTextField.text = pickerData[pickerSelectedIndex]
            extraStreetTextField.text = ""
        } else if activeField == extraStreetTextField {
            extraStreetTextField.text = pickerData[pickerSelectedIndex]
        } else if activeField == derectionAppealTextField {
            derectionAppealTextField.text = pickerData[pickerSelectedIndex]
            eventTypeTextField.text = ""
        } else if activeField == eventTypeTextField {
            eventTypeTextField.text = pickerData[pickerSelectedIndex]
        } else if activeField == appealTypeTextField {
            appealTypeTextField.text = pickerData[pickerSelectedIndex]
        }
        
        hideKeybourd()
    }
    
    func hideKeybourd() {
        
        districtTextField.resignFirstResponder()
        streetTextField.resignFirstResponder()
        extraDistrictTextField.resignFirstResponder()
        extraStreetTextField.resignFirstResponder()
        derectionAppealTextField.resignFirstResponder()
        eventTypeTextField.resignFirstResponder()
        appealTypeTextField.resignFirstResponder()
        
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
    
    func setEnabledTextFields(isEnable: Bool) {
        
        if isEnable {
            
            districtTextField.isEnabled = true
            streetTextField.isEnabled = true
            houseTextField.isEnabled = true
            flatTextField.isEnabled = true
        
        } else {
            
            districtTextField.isEnabled = false
            streetTextField.isEnabled = false
            houseTextField.isEnabled = false
            flatTextField.isEnabled = false
        }
    }
    
    func setPlaceholderColorForAllTextFields() {
        
        let textFields = [
            districtTextField,
            streetTextField,
            houseTextField,
            flatTextField,
            derectionAppealTextField,
            eventTypeTextField,
            describeProblemTextField,
            appealTypeTextField,
            extraDistrictTextField,
            extraStreetTextField,
            extraHouseTextField,
            extraFlatTextField
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
        
        if data is [District] {
            
            for district in data as! [District] {
                pickerData.append(district.name!)
            }
            
        } else if data is [Street] {
            
            for street in data as! [Street] {
                pickerData.append(street.name!)
            }
            
        } else if data is [Problem] {
            
            for problem in data as! [Problem] {
                pickerData.append(problem.name!)
            }
        
        } else if data is [ContactType] {
            
            for contactType in data as! [ContactType] {
                pickerData.append(contactType.name!)
            }
        
        } else if data is [Cause] {
            
            for cause in data as! [Cause] {
                pickerData.append(cause.name!)
            }
        }
        
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
    
    func getCause(by id: Int) {
        
        let parameters: [String : Any] = [
            "culture" : "ua",
            "parentid" : id
        ]
        
        NetworkManager.shared.getCauses(withParameters: parameters, completion: { (response, error) in
            
            guard error == nil else {
                ErrorManager.shered.handleAnError(error: error!, viewController: self)
                return
            }
            
            let causes = response!["list"] as! [NSDictionary]
            
            var causeArray = [Cause]()
            for dictionary in causes {
                
                let cause = Cause(dictionary: dictionary)
                causeArray.append(cause)
            }
            
            SettingManager.shered.saveCauses(causes: causeArray)
            self.setAndReloadPickerData(data: causeArray)
        })
    }
    
    func setNewImage(by parentId: Int, andHeaders headers: [String : String]) {
        
        DispatchQueue.main.async {
    
            if self.collectionData.count > 0 {
                self.sendImage(parentId: parentId, andHeaders: headers)
            } else {
                
                SettingManager.shered.addContact(contact: self.contact)
                self.showAlert(withTitle: "Повідомлення", message: "Звернення відправлено", handler: { (alert) in
                    self.goToMyAppealVC()
                })
            }
        }
    }
    
    func sendImage(parentId: Int, andHeaders: [String : String]) {
        
        var base64Array = [String]()
        if photoIndex < collectionData.count {
            
            let image = collectionData[photoIndex]
                
            let imageData = UIImagePNGRepresentation(image)
            let imageBase64 = imageData?.base64EncodedString()
            
            let parameters: [String : Any] = [
                "parentid" : parentId,
                "ContentBase64" : imageBase64!
            ]
            
            NetworkManager.shared.setNewImage(withParameters: parameters, headers: andHeaders, completion: { (response, error) in
                
                guard error == nil else {
                    ErrorManager.shered.handleAnError(error: error!, viewController: self)
                    return
                }
                print("image sent")
                base64Array.append(imageBase64!)
                
                self.photoIndex += 1
                self.sendImage(parentId: parentId, andHeaders: andHeaders)
            })
        
        } else {
            
            photoIndex = 0
            
            self.contact.imageBase64 = base64Array
            SettingManager.shered.addContact(contact: self.contact)
            
            self.showAlert(withTitle: "Повідомлення", message: "Звернення відправлено", handler: { (alert) in
                self.goToMyAppealVC()
            })
        }
    }
    
    func goToMyAppealVC() {
        
        let myAppealVC = storyboard?.instantiateViewController(withIdentifier: "MyAppealVCID") as! MyAppealVC
        myAppealVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: myAppealVC, action: #selector(myAppealVC.goToMainVC))
        let navigationController = UINavigationController(rootViewController: myAppealVC)
        
        let titleDict: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        navigationController.navigationBar.titleTextAttributes = titleDict
        
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
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

extension SendAppealVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "appealPhotoCell", for: indexPath) as! AppealPhotoCell
        cell.appealImageView.image = collectionData[indexPath.row]
        
        return cell
    }
}
