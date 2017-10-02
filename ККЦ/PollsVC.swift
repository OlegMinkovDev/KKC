//
//  PollsVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 05/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class PollsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let credintial = SettingManager.shered.getCredential()
    var dataArray = [Survey]()
    var currentSurvey = Survey()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getListSurveys(by: SettingManager.shered.getCityId())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Опросы"
    }
    
    // MARK: - CollectionView Delegate & DataSource & FlowLayoutDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pollsCell", for: indexPath) as! PollsCell
        cell.pollsNameLabel.text = dataArray[indexPath.row].about
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentSurvey = dataArray[indexPath.row]
        performSegue(withIdentifier: "toPollsDetailVC", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: Helpful functions
    func getListSurveys(by cityId: Int) {
        
        let stringToConvert = "\(credintial!.token!):"
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credintial!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
            
            let parameters: [String: Any] = [
                "culture" : "ua",
                "city_id" : cityId
            ]
            
            NetworkManager.shared.getListSurveys(withParameters: parameters, headers: headers, completion: { (response, error) in
                
                guard error == nil, response != nil else {
                    ErrorManager.shered.handleAnError(error: error, viewController: self)
                    return
                }
                
                let surveys = response!["surveys"] as! [NSDictionary]
                
                var surveyArray = [Survey]()
                for dictionary in surveys {
                    
                    let used = dictionary["used"] as? Bool
                    
                    let parameters: [String: Any] = [
                        "culture" : "ua",
                        "parentid" : dictionary["id"] as! Int,
                        "city_id" : cityId
                    ]
                    
                    NetworkManager.shared.getSurvey(withParameters: parameters, headers: headers, completion: { (response, error) in
                        
                        guard error == nil, response != nil else {
                            ErrorManager.shered.handleAnError(error: error, viewController: self)
                            return
                        }
                        
                        let survey = Survey(dictionary: response!)
                        survey.used = used
                        surveyArray.append(survey)
                        
                        self.dataArray = surveyArray
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                        SettingManager.shered.saveSurveys(surveys: surveyArray)
                    })
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PollsDetailVC {
            viewController.survey = currentSurvey
        }
    }
    

}
