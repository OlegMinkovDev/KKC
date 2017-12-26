//
//  MyAppealVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 03/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class MyAppealVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var contacts = [Contact]()
    var currentContact = Contact()
    
    var currentContactIndex = 0
    var headers = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        headers = getHeaders()
        
        title = "Мої звернення"
        
        getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI Methods
    @objc func goToMainVC() {
        
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainVCID") as! UINavigationController
        
        DispatchQueue.main.async {
            self.present(mainVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - CollectionView Delegate & DataSource & FlowLayoutDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myAppealCell", for: indexPath) as! MyAppealCell
        
        if let contactId = contacts[indexPath.row].id  {
            print("contact id:", contactId)
        }
        
        if let images = contacts[indexPath.row].images, images.count > 0 {
            cell.photoImageView.image = images[0]
        } else {
            cell.photoImageView.image = UIImage(named: "noImage")
        }
        
        var contactType = ContactType()
        if let contactTypeId = contacts[indexPath.row].typeId {
            contactType = SettingManager.shered.getContactType(by: contactTypeId)!
        }
    
        let problemId = contacts[indexPath.row].problemId!
        let problem = SettingManager.shered.getProblem(by: problemId)
        
        let statusId = contacts[indexPath.row].perfomed
        let status = getStatusById(id: statusId)
        
        if let date = contacts[indexPath.row].reciveDate {
            
            let dateTime = date.split(separator: " ")
            cell.dateLabel.text = "\(dateTime[0]) в \(dateTime[1])"
        }
        
        var nameAppeal = ""
        if let contactTypeName = contactType.name {
            nameAppeal += contactTypeName
        }
        
        if let problem = problem {
            if let problemName = problem.name {
                nameAppeal += " " + problemName
            }
        }
        
        if contacts[indexPath.row].approved == 0 {
            cell.examinedAppealLabel.text = "Нове"
        } else { cell.examinedAppealLabel.text = "" }
        
        cell.nameAppealLabel.text = nameAppeal
        cell.statusLabel.text = status
        cell.textAppealLabel.text = contacts[indexPath.row].note
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        currentContact = contacts[indexPath.row]
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toAppealInfoVC", sender: self)
        }
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
    
    func getContacts() {
        
        NetworkManager.shared.getContacts(headers: SettingManager.HEADERS, completion: { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let contactArray = response!["list"] as! [NSDictionary]
            for dictionary in contactArray {
                
                let contact = Contact(dictionary: dictionary)
                self.contacts.append(contact)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            SettingManager.shered.saveContacts(contacts: self.contacts)
            
            self.getImage()
        })
    }
    
    func getImage() {
        
        if currentContactIndex < contacts.count {
            
            if let contactId = contacts[currentContactIndex].id {
            
                NetworkManager.shared.getImages(by: contactId, headers: headers, completion: { (response, error) in
                    
                    guard error == nil, response != nil else {
                        ErrorManager.shered.handleAnError(error: error, viewController: self)
                        return
                    }
                    
                    if let images = response!["list"] as? [NSDictionary], images.count > 0 {
                        
                        self.contacts[self.currentContactIndex].images = []
                        for dictionary in images {
                            
                            if let base64image = dictionary["ContentBase64"] as? String {
                                
                                if let image = self.decode(base64String: base64image) {
                                    self.contacts[self.currentContactIndex].images?.append(image)
                                }
                            }
                        }
                        
                        self.currentContactIndex += 1
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.getImage()
                        }
                    }
                })
            }
        
        } else {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("END!!!")
        }
    }
    
    func decode(base64String: String?) -> UIImage? {
        
        if let base64String = base64String {
            
            let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
            return UIImage(data: dataDecoded)
        }
        
        return nil
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? AppealInfoVC {
            viewController.contact = currentContact
        }
    }
    

}
