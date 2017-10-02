//
//  AppealDetailVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 03/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class AppealDetailVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var flatLabel: UILabel!
    @IBOutlet weak var appealTypeLabel: UILabel!
    @IBOutlet weak var appealDerectionLabel: UILabel!
    @IBOutlet weak var appealNoteTextView: UITextView!
    
    var collectionData = [UIImage]()
    var contact = Contact()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let images = contact.images, images.count > 0 {
            for image in images {
                collectionData.append(image)
            }
        } else {
            collectionData.append(UIImage(named: "noImage")!)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        if let streetId = contact.streetId {
            let street = SettingManager.shered.getStreet(by: streetId)
            streetLabel.text = street?.name
            districtLabel.text = street?.districtionName
        }
        
        houseLabel.text = contact.house
        flatLabel.text = contact.flat

        if let contactTypeId = contact.typeId {
            let contactType = SettingManager.shered.getContactType(by: contactTypeId)!
            appealTypeLabel.text = contactType.name
        }
        
        if let problemId = contact.problemId {
            let problem = SettingManager.shered.getProblem(by: problemId)
            appealDerectionLabel.text = problem?.name
        }
        
        appealNoteTextView.text = contact.note
        
        navigationItem.backBarButtonItem?.title = ""
    }
    
    // MARK: Helpful functions
    func decode(base64String: String?) -> UIImage? {
        
        if let base64String = base64String {
            
            let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
            return UIImage(data: dataDecoded)
        }
        
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AppealDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
