//
//  MessagesVC.swift
//  ККЦ
//
//  Created by Oleg Minkov on 05/10/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class MessagesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageInputContainerView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let profile = Profile()
    var messages = [Message]()
    var chatroom = Chatroom()
    
    var lastMessageDate = String()
    var updateMessageTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        
        messages = SettingManager.shered.getMessages(roomId: chatroom.id!)
        
        if messages.count > 0 {
            
            lastMessageDate = getCorrectLastMessageDate(sourceDate: messages[messages.count - 1].createDate!) 
            
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
        } else {
            lastMessageDate = chatroom.createDate!
        }
        
        updateMessageTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getMessages), userInfo: nil, repeats: true)
        
        registerForKeyboardNotifications()
        getMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateMessageTimer.invalidate()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: - UI Methods
    @IBAction func sendMessage(_ sender: UIButton) {
        
        let message = Message()
        message.clientId = SettingManager.MY_PROFILE.id!
        message.clientName = SettingManager.MY_PROFILE.name!
        message.text = inputTextField.text
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy.MM.dd в HH:mm:ss"
        var dateString = dateFormater.string(from: Date())
        message.createDate = dateString
        
        messages.append(message)
        SettingManager.shered.addMessage(roomId: chatroom.id!, message: message)
        
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateString = dateFormater.string(from: Date())
        lastMessageDate = dateString
        
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
        addNewMessage()
        
        inputTextField.text = nil
    }
    
    // MARK: - NotificationCenter & Keybourd Events
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        bottomConstraint.constant = keyboardSize.height
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (complation) in
            
            if self.messages.count > 0 {
            
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (complation) in
           
        })
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    
    // MARK: - CollectionView Delegate & DataSource & FlowLayoutDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! MessageCell
        cell.dateLabel.text = messages[indexPath.row].createDate
       
        if let messageText = messages[indexPath.item].text {
            
            // incoming messages
            if SettingManager.MY_PROFILE.id! != messages[indexPath.row].clientId! {
                
                cell.messageLabel.attributedText = getMessageText(withName: messages[indexPath.item].clientName!, andText: messageText)
                let estimatedFrame = calculateCellHeight(withText: cell.messageLabel.text!)
                let estimatedDateFrame = calculateCellHeight(withText: cell.dateLabel.text!)
                
                cell.messageLabel.frame = CGRect(x: 16 + 8, y: 8, width: estimatedFrame.width + 8, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 16, y: 8, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.dateLabel.frame = CGRect(x: 16 - 8, y: cell.textBubbleView.frame.height + 12, width: estimatedDateFrame.width, height: estimatedDateFrame.height)
                
            } else { // outcoming messages
                
                cell.messageLabel.attributedText = getMessageText(withName: messages[indexPath.item].clientName!, andText: messageText)
                let estimatedFrame = calculateCellHeight(withText: cell.messageLabel.text!)
                let estimatedDateFrame = calculateCellHeight(withText: cell.dateLabel.text!)
            
                cell.messageLabel.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16, y: 8, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16, y: 8, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.dateLabel.frame = CGRect(x: view.frame.width - estimatedDateFrame.width - 16, y: cell.textBubbleView.frame.height + 12, width: estimatedDateFrame.width, height: estimatedDateFrame.height)
            }
            
            setShadow(to: cell)
        }
        
        return cell
    }
    
    private func collectionView(_ collectionView: UICollectionView, didDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = messages[indexPath.item].text {
            
            let messageWithName = getMessageText(withName: "Рябушкина Марина", andText: messageText)
            let estimatedFrame = calculateCellHeight(withText: messageWithName.string)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 15 + 20 + 16)
        }
        
        return CGSize(width: view.frame.width, height: 44)
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
    }*/

    // MARK: - Helpful functions
    func setShadow(to cell: MessageCell) {
        
        // add shadow
        cell.textBubbleView.layer.masksToBounds = false
        cell.textBubbleView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.textBubbleView.layer.shadowOpacity = 0.5
        cell.textBubbleView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.textBubbleView.layer.shadowRadius = 3
        
        cell.textBubbleView.layer.shadowPath = UIBezierPath(roundedRect: cell.textBubbleView.bounds, cornerRadius: 12).cgPath
        cell.textBubbleView.layer.shouldRasterize = true
        cell.textBubbleView.layer.rasterizationScale = 1
    }
    
    func getMessageText(withName name: String, andText text: String) -> NSAttributedString {
        
        let messageWithName = "\(name) \n\(text)"
        let blueColor = UIColor(red: 61.0/255.0, green: 109.0/255.0, blue: 173.0/255.0, alpha: 1)
        let nameColorAttr = [NSAttributedStringKey.foregroundColor : blueColor]
        let attrString = NSMutableAttributedString(string: messageWithName)
        attrString.addAttributes(nameColorAttr, range: (messageWithName as NSString).range(of: name))
        
        return attrString
    }
    
    func calculateCellHeight(withText text: String) -> CGRect {
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)], context: nil)
        
        return estimatedFrame
    }
    
    @objc func getMessages() {
        
        let parameters: [String : Any] = [
            "room_id" : chatroom.id!,
            "after_date" : lastMessageDate
        ]
        
        NetworkManager.shared.downloadMessages(withParameters: parameters, headers: SettingManager.HEADERS) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
            
            let count = response!["count"] as! Int
            if count > 0 {
                
                let messageArray = response!["list"] as! [NSDictionary]
                for dictionary in messageArray {
                    
                    let message = Message()
                    message.clientId = dictionary["client_id"] as? Int
                    message.clientName = dictionary["clientname"] as? String
                    message.text = dictionary["text"] as? String
                    message.createDate = self.getCorrectDate(sourceDate: dictionary["create_date"] as! String).displayDate
                    
                    self.lastMessageDate = self.getCorrectDate(sourceDate: dictionary["create_date"] as! String).lastMessageDate
                    
                    self.messages.append(message)
                    
                    SettingManager.shered.addMessage(roomId: self.chatroom.id!, message: message)
                    
                    self.collectionView.reloadData()
                    
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    func addNewMessage() {
        
        let parameters: [String : Any] = [
            "room_id" : chatroom.id!,
            "text" : inputTextField.text!
        ]
        
        NetworkManager.shared.addMessage(withParameters: parameters, headers: SettingManager.HEADERS) { (response, error) in
            
            guard error == nil, response != nil else {
                ErrorManager.shered.handleAnError(error: error, viewController: self)
                return
            }
        }
    }

    func getCorrectDate(sourceDate: String) -> (displayDate: String, lastMessageDate: String) {
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateToDispaly = dateFormatter.date(from: sourceDate)!
        dateFormatter.dateFormat = "yyyy.MM.dd в HH:mm:ss"
        dateFormatter.locale = tempLocale // reset the locale
        
        let calendar = Calendar.current
        let dateToLastMessage = calendar.date(byAdding: .second, value: 1, to: dateToDispaly)
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return (dateFormatter.string(from: dateToDispaly), dateFormatter2.string(from: dateToLastMessage!))
    }
    
    func getCorrectLastMessageDate(sourceDate: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd в HH:mm:ss"
        var date = dateFormatter.date(from: sourceDate)!
        let calendar = Calendar.current
        date = calendar.date(byAdding: .second, value: 1, to: date)!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.string(from: date)
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
