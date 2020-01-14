//
//  LoginViewController.swift
//  lb
//
//  Created by Mac-HOME on 16.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var userID : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        errorLabel.alpha = 0
        
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    // Check the fields and return error msg
    func checkFields() -> String? {
        
        // Check the fields for emptiness
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Пожалуйста, заполните все поля"
        }
        
        return nil
    }
    
    func showActivityIndicator() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.startAnimating();

        alert.view.addSubview(activityIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideActivityIndicator() {
        dismiss(animated: false, completion: nil)
    }
    
    // Transition to the home screen
    func goToHomeScreen() {
        let user = User(uid: userID)
        
        user.loadData() {
            let gameContentManager = GameContentManager()
            
            let homeViewModel = HomeViewModel(user: user, gameContentManager: gameContentManager)
            
            let homeViewController =  self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeTableViewController) as? HomeTableViewController
            
            homeViewController!.viewModel = homeViewModel
            
            self.hideActivityIndicator()
            
            self.view.window?.rootViewController = homeViewController
            self.view.window?.makeKeyAndVisible()
        }
    }

    @IBAction func loginTapped(_ sender: Any) {
        showActivityIndicator()
        
        // Check the fields
        let error = checkFields()
        
        guard error == nil else {
            self.showError(error!)
            hideActivityIndicator()
            return
        }
        
        // Get cleaned data
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to sign in
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil || result == nil {
                self.showError("Неверный email или пароль")
                self.hideActivityIndicator()
            }
            else {
                // Store user id
                self.userID = result!.user.uid
                
                // Transition to the home screen
                self.goToHomeScreen()
            }
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}
