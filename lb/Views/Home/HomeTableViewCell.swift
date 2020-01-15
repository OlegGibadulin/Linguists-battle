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
    
    @IBOutlet weak var statusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ nickname: String) {
        nicknameLabel.text = nickname
    }
    
    func disable() {
        super.isUserInteractionEnabled = false
    }
    
    func enable() {
        super.isUserInteractionEnabled = true
    }
    
    func setVictoryStatus() {
        disable()
        statusImage.image = UIImage(named: "win")
    }
    
    func setDefeatStatus() {
        disable()
        statusImage.image = UIImage(named: "lose")
    }
    
    func setDrawStatus() {
        disable()
        statusImage.image = UIImage(named: "draw")
    }
    
    func setWaitingStatus() {
        disable()
        statusImage.image = UIImage(named: "wait")
    }
    
    func setReadyStatus() {
        enable()
        statusImage.image = UIImage(named: "play")
    }
}
