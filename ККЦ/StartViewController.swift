//
//  StartViewController.swift
//  ККЦ
//
//  Created by Oleg Minkov on 20/09/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let credentials = SettingManager.shered.getCredential()
        
        if credentials != nil {
            
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVCID") as! UINavigationController
            
            DispatchQueue.main.async {
                self.present(mainVC, animated: false, completion: nil)
            }
            
        } else {
            
            let authorizationVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthorizationVCID") as! AuthorizationVC
            
            DispatchQueue.main.async {
                self.present(authorizationVC, animated: false, completion: nil)
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
