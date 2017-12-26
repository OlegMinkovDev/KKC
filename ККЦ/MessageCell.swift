//
//  MessageCell.swift
//  ККЦ
//
//  Created by Oleg Minkov on 06/10/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var textBubbleView: UIView!
    @IBOutlet weak var dateLabel: CustomLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageLabel.backgroundColor = .clear
        self.textBubbleView.backgroundColor = .white
        
        self.textBubbleView.layer.cornerRadius = 15
        //self.textBubbleView.layer.masksToBounds = true
    }
}
