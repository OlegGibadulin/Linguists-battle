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
    
    @IBOutlet weak var qestionLabel: UILabel!
    
    @IBOutlet var answerButtons: [UIButton]!
    
    @IBOutlet weak var nextQestionButton: UIButton!
    
    @IBOutlet weak var goToHomeButton: UIButton!
    
    var db: Firestore!
    
    let questionsCount = 2
    var questionsList: [String] = []
    var questionCurInd = 0
    
    var correctAnswersList: [String] = []
    var correctAnswerInd = 0
    
    let wrongAnswersCount = 3
    var wrongAnswersList: [[String]] = []
    
    var userCorrectAnswersCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        db = Firestore.firestore()
        
        
        setUpElements()
        disableAnswerButtons()
        
        // Load game
        if (isThereOpponentGame()) {
            loadOpponentGame()
        }
        else {
            createNewGame()
        }
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
    
    // Check for saved opponent game
    func isThereOpponentGame() -> Bool {
        return false
    }
    
    // Load lists of questions, correct and wrong answers from opponent game
    func loadOpponentGame() {
        
    }
    
    // Load lists of random questions, correct and wrong answers
    func createNewGame() {
        
        db.collection("words").document("categories").getDocument { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            // Get random category
            let categoriesList = snapshot!.data()!["list"] as! [String]
            
            let categoryInd = Int.random(in: 0 ..< categoriesList.count)
            let category = categoriesList[categoryInd]
            
            // Get lists of random words from this category
            self.db.collection("words").document(category).getDocument { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                let words = snapshot!.data()!["list"] as! [String:String]
                let keys = Array(words.keys)
                
                for _ in 0 ..< self.questionsCount {
                    
                    let wordInd = Int.random(in: 0 ..< keys.count)
                    
                    self.questionsList.append(keys[wordInd])
                    self.correctAnswersList.append(words[keys[wordInd]]!)
                    
                    // Get list of random incorrect choices
                    while true {
                        var areNotFounded = false
                        var incorrectWordInds: [Int] = []
                        
                        for _ in 0 ..< self.wrongAnswersCount {
                            incorrectWordInds.append(Int.random(in: 0 ..< keys.count))
                        }
                        
                        // Check for repeated indexes
                        for i in 0 ..< self.wrongAnswersCount {
                            if incorrectWordInds[i] == incorrectWordInds[(i + 1) % self.wrongAnswersCount] {
                                areNotFounded = true
                                break
                            }
                        }
                        
                        // Check for equality with correct choise
                        for i in 0 ..< self.wrongAnswersCount {
                            if incorrectWordInds[i] == wordInd {
                                areNotFounded = true
                                break
                            }
                        }
                        
                        if areNotFounded { continue }
                        
                        var incorrectChoices: [String] = []
                        
                        for i in 0 ..< self.wrongAnswersCount {
                            let word = words[keys[incorrectWordInds[i]]]!
                            incorrectChoices.append(word)
                        }
                        
                        self.wrongAnswersList.append(incorrectChoices)
                        
                        break
                    }
                }
                
                self.saveGame()
                self.setWords()
            }
        }
    }
    
    // Save lists of questions, correct and wrong answers for opponent
    func saveGame() {
        
    }
    
    // Set up labels of current question and answers
    func setWords() {
        
        enableAnswerButtons()
        
        qestionLabel.text = questionsList[questionCurInd]
        
        // Random answer button
        correctAnswerInd = Int.random(in: 0 ..< answerButtons.count)
        
        var wrongAnswersInd = 0
        
        for i in 0 ..< answerButtons.count {
            
            if i == correctAnswerInd {
                let answer = correctAnswersList[questionCurInd]
                answerButtons[i].setTitle(answer, for: .normal)
            }
            else {
                let answer = wrongAnswersList[questionCurInd][wrongAnswersInd]
                answerButtons[i].setTitle(answer, for: .normal)
                wrongAnswersInd += 1
            }
        }
    }
    
    // Save user score
    func saveScore() {
        
    }
    
    // Check answer for correctness
    @IBAction func answerTapped(_ sender: UIButton) {
        
        disableAnswerButtons()
        
        nextQestionButton.isHidden = false
        
        // Set correct button green
        Utilities.styleCorrectAnswerButton(answerButtons[correctAnswerInd])
        userCorrectAnswersCount += 1
        
        // Set wrong button red if tapped
        for i in 0 ..< answerButtons.count {
            
            if answerButtons[i] == sender && i != correctAnswerInd {
                Utilities.styleWrongAnswerButton(sender)
                userCorrectAnswersCount -= 1
            }
        }
        
        saveScore()
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
        
        if questionCurInd == questionsCount - 1 {
            hideElements()
            
            // Display score
            qestionLabel.text = String(userCorrectAnswersCount) + " / " + String(questionsCount)
            
            // Display button for transition to the home screen
            goToHomeButton.isHidden = false
        }
        else {
            questionCurInd += 1
            
            setUpElements()
            setWords()
        }
    }
    
    // Transition to the home screen
    @IBAction func goToHomeScreenTapped(_ sender: Any) {
        let homeViewController =  storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeTableViewController) as? HomeTableViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}
