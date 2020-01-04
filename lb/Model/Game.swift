//
//  Game.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Foundation

class Game {
    var ID: String = ""
    var userIsCreator: Bool = false
    
    let questionsCount = 2
    var questionsList: [String] = []
    var questionCurInd = 0
    
    var correctAnswersList: [String] = []
    var correctAnswerInd = 0
    
    let wrongAnswersCount = 3
    var wrongAnswersList: [[String]] = []
    
    var userCorrectAnswersCount = 0
    
    
    
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
                    
                    var wordInd = Int.random(in: 0 ..< keys.count)
                    
                    while self.questionsList.contains(keys[wordInd]) {
                        wordInd = Int.random(in: 0 ..< keys.count)
                    }
                    
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
}
