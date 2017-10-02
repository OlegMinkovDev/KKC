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
    var variantsArray = [String]()
    var questionIndex = Int()
    var radioButtons = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getQuestion(by: self.questionIndex)
    }

    /*@IBAction func radioButton1Tap(_ sender: UIButton) {
        setSelectedRadioButton(sender)
    }
    
    @IBAction func radioButton2Tap(_ sender: UIButton) {
        setSelectedRadioButton(sender)
    }
    
    @IBAction func radioButton3Tap(_ sender: UIButton) {
        setSelectedRadioButton(sender)
    }
    
    @IBAction func radioButton4Tap(_ sender: UIButton) {
        setSelectedRadioButton(sender)
    }*/
    
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
    
    // MARK: - UI Methods
    @IBAction func send(_ sender: UIButton) {
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
        cell.answerLabel.text = variantsArray[indexPath.row]
        cell.selectionStyle = .none
        
        radioButtons.append(cell.radioButton)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! AnswerCell
        setSelectedRadioButton(cell.radioButton)
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
                        variantsArray.append(variant.name!)
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
