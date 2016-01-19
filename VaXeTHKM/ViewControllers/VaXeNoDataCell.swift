//
//  VaXeNoDataCell.swift
//  VaXeTHKM
//
//  Created by Thanh Tran on 11/4/15.
//  Copyright © 2015 vaxe. All rights reserved.
//

import UIKit

class VaXeNoDataCell: UITableViewCell {
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewBG.layer.cornerRadius = 5
        self.viewBG.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewBG.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.viewBG.layer.shadowOpacity = 0.5
        self.viewBG.layer.shadowRadius = 2
        self.viewBG.clipsToBounds = false
        self.viewBG.layer.masksToBounds = false
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func showOthers(sender: AnyObject) {
    }
    
    

}
