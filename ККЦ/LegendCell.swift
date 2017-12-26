//
//  LegendCell.swift
//  ККЦ
//
//  Created by Oleg Minkov on 15/10/2017.
//  Copyright © 2017 Oleg Minkov. All rights reserved.
//

import UIKit

class LegendCell: UITableViewCell {
    
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var legendTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
