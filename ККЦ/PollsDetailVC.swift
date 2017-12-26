//
//  PollsDetailVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 05/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class PollsDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var radioButton1: UIButton!
    @IBOutlet weak var radioButton2: UIButton!
    @IBOutlet weak var radioButton3: UIButton!
    @IBOutlet weak var radioButton4: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var survey = Survey()
    var variantsArray = [Variant]()
    var questionIndex = Int()
    var radioButtons = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getQuestion(by: self.questionIndex)
    }
    
    // MARK: - UI Methods
    @IBAction func send(_ sender: UIButton) {
        
        let credintial = SettingManager.shered.getCredential()
        
        let stringToConvert = "\(credintial!.token!):"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credintial!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
            
            let parameters = survey.converToDictionary()
            
            NetworkManager.shared.addAnswersOnSurvey(withParameters: parameters, headers: headers, completion: { (response, error) in
                
                guard error == nil else {
                    ErrorManager.shered.handleAnError(error: error!, viewController: self)
                    return
                }
                
                let alertController = UIAlertController(title: "Повідомлення", message: "Опитування успішно пройдено", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { alert in
                    
                    let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVCID") as! UINavigationController
                    
                    DispatchQueue.main.async {
                        self.present(mainVC, animated: true, completion: nil)
                    }
                })
                alertController.addAction(alertAction)
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: false, completion: nil)
                }
            })
        }
    }
    
    @IBAction func nextQuestion(_ sender: UIBarButtonItem) {
        
        questionIndex += 1
        getQuestion(by: questionIndex)
    }
    
    // MARK: - TableView Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variantsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell") as! AnswerCell
        cell.answerLabel.text = variantsArray[indexPath.row].name
        cell.selectionStyle = .none
        cell.radioButton.tag = indexPath.row
        cell.radioButton.addTarget(self, action: #selector(radioButtonTap), for: .touchUpInside)
        
        cell.radioButton.isSelected = false
        if indexPath.row == 0 {
            cell.radioButton.isSelected = true
        }
        
        radioButtons.append(cell.radioButton)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! AnswerCell
        setSelectedRadioButton(cell.radioButton)
        setRightVariant(variantId: variantsArray[indexPath.row].id!)
    }
    
    @objc func radioButtonTap(sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! AnswerCell
        setSelectedRadioButton(cell.radioButton)
        setRightVariant(variantId: variantsArray[indexPath.row].id!)
    }
    
    // MARK: - Helpful functions
    func getQuestion(by index: Int) {
        
        if let fields = survey.fields {
        
            if index < fields.count {
                
                if index == fields.count - 1 {
                    
                    navigationItem.rightBarButtonItem = nil
                    sendButton.isEnabled = true
                }
                
                DispatchQueue.main.async {
                    self.questionLabel.text = fields[index].about
                }
                
                if let variants = fields[index].variants {
                    
                    variantsArray = []
                    for variant in variants {
                        variantsArray.append(variant)
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.tableViewHeightConstraint.constant = CGFloat(44 * variants.count)
                        self.tableView.reloadData()
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.layoutIfNeeded()
                        })
                    }
                }
            
            }
        }
    }
    
    func setSelectedRadioButton(_ button: UIButton) {
        
        if !button.isSelected {
            button.isSelected = !button.isSelected
            
            for rb in radioButtons {
                if rb != button {
                    rb.isSelected = false
                }
            }
        }
    }
    
    func setRightVariant(variantId: Int) {
        
        for variant in variantsArray {
            if variant.id == variantId {
                variant.isChecked = true
            } else { variant.isChecked = false }
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
