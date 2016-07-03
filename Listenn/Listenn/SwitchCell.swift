//
//  SwitchCell.swift
//  Listenn
//
//  Created by Monte with Pillow on 7/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
