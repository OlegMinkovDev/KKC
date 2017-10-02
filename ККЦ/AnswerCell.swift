//
//  AnswerCell.swift
//  ККЦ
//
//  Created by Oleg Minkov on 29/09/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell {

    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
