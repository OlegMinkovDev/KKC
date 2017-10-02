//
//  AppealInfoVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 03/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class AppealInfoVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var appealStatusLabel: UILabel!
    @IBOutlet weak var appealDateLabel: UILabel!
    @IBOutlet weak var contactTypeProblemLabel: UILabel!
    @IBOutlet weak var sentToOrganizationLabel: UILabel!
    @IBOutlet weak var responseToAppealLabel: UILabel!
    @IBOutlet weak var appealDetail: UIView!
    @IBOutlet weak var appealResultTextField: UITextField!
    @IBOutlet weak var ratingPerformerTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var postReviewButton: UIButton!
    
    var pickerView = UIPickerView()
    var activeField: UITextField?
    
    var pickerSelectedIndex = Int()
    var pickerData = [String]()
    
    let screenSize = UIScreen.main.bounds.size
    
    var contact = Contact()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appealDetailTap = UITapGestureRecognizer(target: self, action: #selector(goToAppealDetail))
        appealDetail.addGestureRecognizer(appealDetailTap)
        
        let picker = createPickerAndAccessoryView()
        pickerView = picker.pickerView
        
        appealResultTextField.inputView = picker.pickerView
        appealResultTextField.inputAccessoryView = picker.accessoryView
        ratingPerformerTextField.inputView = picker.pickerView
        ratingPerformerTextField.inputAccessoryView = picker.accessoryView
        
        let status = getStatusById(id: contact.perfomed)
        appealStatusLabel.text = status
        
        if let date = contact.reciveDate {
            appealDateLabel.text = date
        }
        
        var contactType = ContactType()
        if let contactTypeId = contact.typeId {
            contactType = SettingManager.shered.getContactType(by: contactTypeId)!
        }
        
        let problemId = contact.problemId!
        let problem = SettingManager.shered.getProblem(by: problemId)
        
        var nameAppeal = ""
        if let contactTypeName = contactType.name {
            nameAppeal += contactTypeName
        }
        
        if let problem = problem {
            if let problemName = problem.name {
                nameAppeal += " " + problemName
            }
        }
        
        if let serviceId = contact.execId {
            if let service = SettingManager.shered.getUtilities(by: serviceId) {
                sentToOrganizationLabel.text = service.name
            }
        }
        
        contactTypeProblemLabel.text = nameAppeal
        
        let screenSingleTap = UITapGestureRecognizer(target: self, action: #selector(screenTapAction))
        view.addGestureRecognizer(screenSingleTap)
        
        registerForKeyboardNotifications()
        setPlaceholderColorForAllTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCCResult()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: - UI Methods
    @IBAction func postReview(_ sender: UIButton) {
        
        let headers = getHeaders()
        
        let parametersForReview: [String : Any] = [
            "cc_id" : contact.id!,
            "review": appealResultTextField.text!
        ]
        let parametersForResultScore: [String : Any] = [
            "cc_id": self.contact.id!,
            "score": Int(self.ratingPerformerTextField.text!)!
        ]
        let parametersForResultComment: [String : Any] = [
            "cc_id": self.contact.id!,
            "comment": self.commentTextField.text!,
        ]
        
        NetworkManager.shared.setCCReview(withParameters: parametersForReview, headers: headers) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            NetworkManager.shared.setCCResultScore(withParameters: parametersForResultScore, headers: headers, completion: { (response, error) in
                
                guard error == nil, response != nil else {
                    ErrorManager.shered.handleAnError(error: error, viewController: self)
                    return
                }
                
                NetworkManager.shared.setCCResultComment(withParameters: parametersForResultComment, headers: headers, completion: { (response, error) in
                    
                    guard error == nil, response != nil else {
                        ErrorManager.shered.handleAnError(error: error, viewController: self)
                        return
                    }
                    
                    self.showAlert(withTitle: "Повідомлення", message: "Відгук відправлений")
                    
                    DispatchQueue.main.async {
                        
                        self.appealResultTextField.text = nil
                        self.ratingPerformerTextField.text = nil
                        self.commentTextField.text = nil
                    }
                })
            })
        }
    }
    
    @objc func screenTapAction() {
        view.endEditing(true)
    }
    
    @objc func goToAppealDetail() {
        performSegue(withIdentifier: "toAppealDetailVC", sender: self)
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
        scrollView.isScrollEnabled = false
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
        
        if textField == appealResultTextField {
            
            pickerData = ["Результат задовольнив", "Результат не задовольнив"]
            
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
            
        } else if textField == ratingPerformerTextField {
            
            pickerData = ["1", "2", "3", "4", "5"]
            
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
        
        if appealResultTextField.text != "" && ratingPerformerTextField.text != "" && commentTextField.text != "" {
            postReviewButton.isEnabled = true
        } else {
            postReviewButton.isEnabled = false
        }
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
        
        if activeField == appealResultTextField {
            appealResultTextField.text = pickerData[pickerSelectedIndex]
        } else if activeField == ratingPerformerTextField {
            ratingPerformerTextField.text = pickerData[pickerSelectedIndex]
        }
        
        hideKeybourd()
    }
    
    func hideKeybourd() {
        
        appealResultTextField.resignFirstResponder()
        ratingPerformerTextField.resignFirstResponder()
        
        pickerSelectedIndex = 0
    }
    
    // MARK: - Helpful functions
    func getStatusById(id: String?) -> String {
        
        if id != nil {
            
            let index = Int(id!)
            
            if index == Status.inWork.rawValue {
                return "В роботі"
            } else if index == Status.completePositive.rawValue {
                return "Опрацьовано"
            } else if index == Status.completeExplained.rawValue {
                return "Дано роз'яснення"
            } else if index == Status.complateDeclined.rawValue {
                return "У виконанні відмовлено"
            } else {
                return "Не потребує відповіді"
            }
        } else {
            return "В роботі"
        }
    }
    
    func setPlaceholderColorForAllTextFields() {
        
        let textFields = [
            appealResultTextField,
            ratingPerformerTextField,
            commentTextField
        ]
        
        for textField in textFields {
            
            if let placeholder = textField?.placeholder {
                
                textField?.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                      attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
            }
        }
    }

    func getCCResult() {
        
        let headers = getHeaders()
        
        NetworkManager.shared.getCCResult(by: contact.id!, headers: headers, completion: { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            DispatchQueue.main.async {
                self.responseToAppealLabel.text = response!["text"] as? String
            }
        })
    }
    
    func getHeaders() -> [String : String] {
        
        let credintial = SettingManager.shered.getCredential()
        
        let stringToConvert = "\(credintial!.token!):"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credintial!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
         
            return headers
        }
        
        return [:]
    }
    
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? AppealDetailVC {
            viewController.contact = contact
        }
    }
    

}
