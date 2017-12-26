//
//  MainVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 31/07/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let icons = ["chatBubble", "archive", "diagram", "user", "info", "chatBubbles", "question", "book", "phone"]
    let titles = ["Надіслати звернення", "Мої звернення", "Статистика звернень", "Мій Профіль", "Сповіщення", "Онлайн чат", "Опитування", "Корисна інформація", "Контакти"]
    
    let credintial = SettingManager.shered.getCredential()
    var dnieperId = SettingManager.shered.getCityId()
    let screenSize = UIScreen.main.bounds.size
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleDict: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        
        title = "Назад"
        
        SettingManager.shered.updateHeaders()
        
        getCities()
        
        DispatchQueue.global().async {
            
            self.getMyProfile()
            self.getDistricts(by: self.dnieperId)
            self.getStreet(by: self.dnieperId)
            self.getClientCategory(by: self.dnieperId)
            self.getContactTypes()
            self.getProblemList()
            self.getKPList()
            self.getContacts()
            self.getListAlarmAlerts()
        }
    }
    
    // MARK: - CollectionView Delegate & DataSource & DelegateFlowLayout
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MainMenuCell
        cell.title.text = titles[indexPath.row]
        cell.icon.image = UIImage(named: icons[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "toSendAppealVC", sender: self)
        case 1:
            performSegue(withIdentifier: "toMyAppealVC", sender: self)
        case 2:
            performSegue(withIdentifier: "toAppealStatisticsVC", sender: self)
        case 3:
            performSegue(withIdentifier: "toMyProfileVC", sender: self)
        case 4:
            performSegue(withIdentifier: "toAboutAppVC", sender: self)
        case 5:
            performSegue(withIdentifier: "toOnlineChatVC", sender: self)
        case 6:
            performSegue(withIdentifier: "toPollsVC", sender: self)
        case 7:
            performSegue(withIdentifier: "toHelpfulInformationVC", sender: self)
        case 8:
            performSegue(withIdentifier: "toContactVC", sender: self)
        default:
            // assertionFailure("ERROR")
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var correctSize: CGSize!
        
        if screenSize.height == 480 {
            correctSize = CGSize(width: 75, height: 75)
        } else if screenSize.height == 568 {
            correctSize = CGSize(width: 89, height: 89)
        } else if screenSize.height == 667 {
            correctSize = CGSize(width: 105, height: 105)
        } else {
            correctSize = CGSize(width: 120, height: 120)
        }
        
        return correctSize
    }
    
    // MARK: - Helpful functions
    func getCities() {
        
        let parameters: [String: Any] = [
            "culture" : "ua",
            "cityid" : 0
        ]
        
        NetworkManager.shared.getCities(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            var cityArray = [City]()
            
            let listCities = response!["list"] as! [NSDictionary]
            for dictionary in listCities {
                
                let city = City(dictionary: dictionary)
                cityArray.append(city)
            }
            
            self.dnieperId = cityArray[0].id!
            
            SettingManager.shered.saveCities(cities: cityArray)
        }
    }
    
    func getDistricts(by cityId: Int) {
        
        let parameters: [String: Any] = [
            "culture" : "ua",
            "cityid" : cityId
        ]
        
        NetworkManager.shared.getDistricts(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let districts = response!["list"] as! [NSDictionary]
            
            var districtArray = [District]()
            for dictionary in districts {
                
                let district = District(dictionary: dictionary)
                districtArray.append(district)
            }
            
            SettingManager.shered.saveDistricts(districts: districtArray)
        }
    }
    
    func getStreet(by cityId: Int) {
        
        let parameters: [String: Any] = [
            "culture" : "ua",
            "cityid" : cityId
        ]
        
        NetworkManager.shared.getStreets(withParameters: parameters) { (response, error) in
            
            guard error == nil, let response = response else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let streets = response["list"] as! [NSDictionary]
            
            var streetArray = [Street]()
            for dictionary in streets {
                
                let street = Street(dictionary: dictionary)
                streetArray.append(street)
            }
            
            SettingManager.shered.saveStreets(streets: streetArray)
        }
    }
    
    func getClientCategory(by cityId: Int) {
        
        let parameters: [String: Any] = [
            "culture" : "ua",
            "cityid" : cityId
        ]
        
        NetworkManager.shared.getClientCategories(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let clientCategories = response!["list"] as! [NSDictionary]
            
            var clientCategoryArray = [ClientCategory]()
            for dictionary in clientCategories {
                
                let clientCategory = ClientCategory(dictionary: dictionary)
                clientCategoryArray.append(clientCategory)
            }
            
            SettingManager.shered.saveClientCategories(clientCategories: clientCategoryArray)
        }
    }
    
    func getKPList() {
        
        let parameters: [String: Any] = [
            "culture" : "ua"
        ]
        
        NetworkManager.shared.getKPList(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let utilities = response!["list"] as! [NSDictionary]
            
            var utilitiesArray = [Utilities]()
            for dictionary in utilities {
                
                let service = Utilities(dictionary: dictionary)
                utilitiesArray.append(service)
            }
            
            SettingManager.shered.saveUtilities(utilities: utilitiesArray)
        }
    }
    
    func getContactTypes() {
        
        let parameters: [String: Any] = [
            "culture" : "ua"
        ]
        
        NetworkManager.shared.getCCTypeList(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let contactTypes = response!["list"] as! [NSDictionary]
            
            var contactTypeArray = [ContactType]()
            for dictionary in contactTypes {
                
                let contactType = ContactType(dictionary: dictionary)
                contactTypeArray.append(contactType)
            }
            
            SettingManager.shered.saveContactTypes(contactTypes: contactTypeArray)
        }
    }
    
    func getProblemList() {
        
        let parameters: [String: Any] = [
            "culture" : "ua"
        ]
        
        NetworkManager.shared.getProblemList(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let problems = response!["list"] as! [NSDictionary]
            
            var problemArray = [Problem]()
            for dictionary in problems {
                
                let problem = Problem(dictionary: dictionary)
                problemArray.append(problem)
            }
            
            SettingManager.shered.saveProblems(problems: problemArray)
        }
    }
    
    func getContacts() {
        
        NetworkManager.shared.getContacts(headers: SettingManager.HEADERS, completion: { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let contacts = response!["list"] as! [NSDictionary]
            
            var contactArray = [Contact]()
            for dictionary in contacts {
                
                let contact = Contact(dictionary: dictionary)
                contactArray.append(contact)
            }
            
            SettingManager.shered.saveContacts(contacts: contactArray)
        })
    }
    
    func getMyProfile() {
        
        NetworkManager.shared.getMyProfile(withHeaders: SettingManager.HEADERS, completion: { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let myProfile = Profile(parameters: response!)
            SettingManager.MY_PROFILE = myProfile
        })
    }
    
    func getListAlarmAlerts() {
        
        let parameters: [String : Any] = [
            "culture" : "ua",
            "city_id" : dnieperId
        ]
        print(parameters)
        NetworkManager.shared.getListAlarmAlerts(withParameters: parameters) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let alerts = response!["list"] as! [NSDictionary]
            
            var alertArray = [Alert]()
            for dictionary in alerts {
                
                let alert = Alert(dictionary: dictionary)
                alertArray.append(alert)
            }
            
            SettingManager.shered.saveAlerts(alerts: alertArray)
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
