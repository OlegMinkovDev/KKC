//
//  AppealPhotoCell.swift
//  ККЦ
//
//  Created by Oleg Minkov on 30/09/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class AppealPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var appealImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
    }
}
