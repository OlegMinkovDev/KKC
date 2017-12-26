//
//  OnlineChatVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 04/08/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class OnlineChatVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var chatrooms = [Chatroom]()
    var currentChatroom = Chatroom()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getListMyChatrooms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Онлайн чат"
    }
    
    // MARK: - CollectionView Delegate & DataSource & FlowLayoutDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatCell", for: indexPath) as! ChatCell
        
        cell.nameLabel.text = chatrooms[indexPath.row].name
        cell.aboutLabel.text = chatrooms[indexPath.row].about
        cell.operatorLabel.text = chatrooms[indexPath.row].moderatorName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentChatroom = chatrooms[indexPath.row]
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toMessagesVC", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 68)
    }
    
    // MARK: Helpful functions
    func getListMyChatrooms() {
        
        chatrooms = []
        
        NetworkManager.shared.listMyChatrooms(headers: SettingManager.HEADERS) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let chatroomArray = response!["list"] as! [NSDictionary]
            for dictionary in chatroomArray {
                
                let chatroom = Chatroom(dictionary: dictionary)
                self.chatrooms.append(chatroom)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? MessagesVC {
            viewController.chatroom = currentChatroom
        }
    }
    

}
