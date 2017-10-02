//
//  OnlineChatVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 04/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class OnlineChatVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var enterMessageTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        attachmentButton.imageView?.contentMode = .scaleAspectFit
        sendMessageButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Онлайн чат"
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
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
