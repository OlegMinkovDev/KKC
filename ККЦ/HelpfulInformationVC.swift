//
//  HelpfulInformationVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 04/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class HelpfulInformationVC: UIViewController {

    @IBOutlet weak var textLabel: CustomLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Корисна інформація"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        getHelpfulInfo()
    }
    
    // MARK: Helpful functions
    func getHelpfulInfo() {
        
        NetworkManager.shared.getMiscInfo { (response, error) in
            
            guard error == nil, let response = response else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            DispatchQueue.main.async {
                self.textLabel.text = response["text"] as? String
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
