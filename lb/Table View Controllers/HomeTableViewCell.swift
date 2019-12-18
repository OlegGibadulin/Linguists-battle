//
//  HomeTableViewCell.swift
//  lb
//
//  Created by Mac-HOME on 18.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ nickname: String) {
        nicknameLabel.text = nickname
    }
}
