//
//  ArticleCell.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/4/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

protocol ArticleCellDelegate: class {
    func playSoundButtonClicked (articleCell: ArticleCell!)
    func getInfoButtonClicked (articleCell: ArticleCell!)
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var playSoundButton: UIButton!
    
    var buttonDelegate: ArticleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func playSoundButtonClicked(sender: AnyObject) {
        print("Play sound button clicked")
        buttonDelegate?.playSoundButtonClicked(self)
    }
    
    @IBAction func getInfoButtonClicked(sender: AnyObject) {
        print("Get info button clicked")
        buttonDelegate?.getInfoButtonClicked(self)
    }
}
