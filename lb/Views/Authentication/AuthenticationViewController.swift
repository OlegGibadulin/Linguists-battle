//
//  ViewController.swift
//  lb
//
//  Created by Mac-HOME on 16.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }


}

