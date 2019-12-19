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
    var db: Firestore!
    
    let questionsCount = 1
    var questionsList: [String] = []
    var questionCurInd = 0
    
    var correctAnswersList: [String] = []
    var correctAnswerInd = 0
    
    let wrongAnswersCount = 3
    var wrongAnswersList: [[String]] = []
    
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
                            incorrectWordInds.append(Int.random(in: 0 ..< self.wrongAnswersCount))
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
    
    // Set up current question
    func setWords() {
        qestionLabel.text = questionsList[questionCurInd]
        
        correctAnswerInd = Int.random(in: 0 ..< answerButtons.count)
        var wrongAnswersInd = 0
        
        for i in 0 ..< answerButtons.count {
            
            if i == correctAnswerInd {
                answerButtons[i].titleLabel?.text = correctAnswersList[questionCurInd]
            }
            else {
                answerButtons[i].titleLabel?.text = wrongAnswersList[questionCurInd][wrongAnswersInd]
                wrongAnswersInd += 1
            }
        }
        
        print(questionsList)
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
    }

}
