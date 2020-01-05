//
//  HomeViewController.swift
//  lb
//
//  Created by Mac-HOME on 16.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import UIKit
import Firebase

class GameViewController: UIViewController {
    
    var viewModel: GameViewModel! {
            didSet {
                setWords()
            }
        }
    
    @IBOutlet weak var qestionLabel: UILabel!
    
    @IBOutlet var answerButtons: [UIButton]!
    
    @IBOutlet weak var nextQestionButton: UIButton!
    
    @IBOutlet weak var goToHomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
        disableAnswerButtons()
    }
    
    func setUpElements() {
        
        goToHomeButton.isHidden = true
        
        for i in 0 ..< answerButtons.count {
            Utilities.styleHollowButton(answerButtons[i])
        }
        
        Utilities.styleHollowButton(nextQestionButton)
        nextQestionButton.isHidden = true
    }
    
    func disableAnswerButtons() {
        for i in 0 ..< answerButtons.count {
            answerButtons[i].isEnabled = false
        }
    }
    
    func enableAnswerButtons() {
        for i in 0 ..< answerButtons.count {
            answerButtons[i].isEnabled = true
        }
    }
    
    // Set up labels of current question and answers
    func setWords() {
        
        enableAnswerButtons()
        
        qestionLabel.text = viewModel.getCurQuestion()
        
        // Random answer button
        let correctAnswerInd = viewModel.createCorrectAnswerInd()
        
        var wrongAnswersInd = 0
        
        for i in 0 ..< answerButtons.count {
            
            if i == correctAnswerInd {
                let answer = viewModel.getCurAnswer()
                answerButtons[i].setTitle(answer, for: .normal)
            }
            else {
                let answer = viewModel.getCurWrongAnswer(at: wrongAnswersInd)
                answerButtons[i].setTitle(answer, for: .normal)
                wrongAnswersInd += 1
            }
        }
    }
    
    // Check answer for correctness
    @IBAction func answerTapped(_ sender: UIButton) {
        
        disableAnswerButtons()
        
        nextQestionButton.isHidden = false
        
        // Set correct button green
        Utilities.styleCorrectAnswerButton(answerButtons[viewModel.getCorrectAnswerInd()])
        
        viewModel.increaseUserScore()
        
        // Set wrong button red if tapped
        for i in 0 ..< answerButtons.count {
            
            if answerButtons[i] == sender && i != viewModel.getCorrectAnswerInd() {
                Utilities.styleWrongAnswerButton(sender)
                viewModel.decreaseUserScore()
            }
        }
        
        viewModel.saveUserScore()
    }
    
    // Hide answer and next buttons
    func hideElements() {
        for i in 0 ..< answerButtons.count {
            answerButtons[i].isHidden = true
        }
        
        nextQestionButton.isHidden = true
    }
    
    // Go to next question
    @IBAction func nextQestionTapped(_ sender: Any) {
        
        if viewModel.isGameOver() {
            hideElements()
            
            // Display score
            qestionLabel.text = viewModel.getUserResults()
            
            // Display button for transition to the home screen
            goToHomeButton.isHidden = false
        }
        else {
            viewModel.increaseQuestionIndex()
            
            setUpElements()
            setWords()
        }
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
    @IBAction func goToHomeScreenTapped(_ sender: Any) {
        showActivityIndicator()
        
        let user = User(uid: Constants.User.id!)
        
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
}
