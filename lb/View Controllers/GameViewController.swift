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
    
    var db: Firestore!
    
    let questionsCount = 2
    var questionsList: [String] = []
    var questionCurInd = 0
    
    var correctAnswersList: [String] = []
    var correctAnswerInd = 0
    
    let wrongAnswersCount = 3
    var wrongAnswersList: [[String]] = []
    
    var a = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        db = Firestore.firestore()
        
        setUpElements()
        loadWords()
    }
    
    func setUpElements() {
        
        for i in 0 ..< answerButtons.count {
            Utilities.styleHollowButton(answerButtons[i])
        }
        
        Utilities.styleHollowButton(nextQestionButton)
        nextQestionButton.isHidden = true
    }
    
    // Load lists of questions, answers and wrong answers
    func loadWords() {
        
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
                
                self.setWords()
            }
        }
    }
    
    // Set up labels of current question and answers
    func setWords() {
        qestionLabel.text = questionsList[questionCurInd]
        
        correctAnswerInd = Int.random(in: 0 ..< answerButtons.count)
        var wrongAnswersInd = 0
        
        for i in 0 ..< answerButtons.count {
            
            answerButtons[i].isEnabled = true
            
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
    
    // Check answer for correctness
    @IBAction func answerTapped(_ sender: UIButton) {
        
        nextQestionButton.isHidden = false
        
        // Set correct button green
        Utilities.styleCorrectAnswerButton(answerButtons[correctAnswerInd])
        
        // Set wrong button red if tapped
        for i in 0 ..< answerButtons.count {
            
            answerButtons[i].isEnabled = false
            
            if answerButtons[i] == sender {
                
                if i != correctAnswerInd {
                    Utilities.styleWrongAnswerButton(sender)
                }
            }
        }
    }
    
    // Go to next question
    @IBAction func nextQestionTapped(_ sender: Any) {
        questionCurInd += 1
        
        if questionCurInd >= questionsCount {
            
        }
        else {
            setUpElements()
            setWords()
        }
    }
}
