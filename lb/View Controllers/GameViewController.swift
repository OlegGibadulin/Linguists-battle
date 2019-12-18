//
//  HomeViewController.swift
//  lb
//
//  Created by Mac-HOME on 16.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var qestionLabel: UILabel!
    
    @IBOutlet weak var answerButton1: UIButton!
    
    @IBOutlet weak var answerButton2: UIButton!
    
    @IBOutlet weak var answerButton3: UIButton!
    
    @IBOutlet weak var answerButton4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {
        
        Utilities.styleHollowButton(answerButton1)
        Utilities.styleHollowButton(answerButton2)
        Utilities.styleHollowButton(answerButton3)
        Utilities.styleHollowButton(answerButton4)
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
    }

}
