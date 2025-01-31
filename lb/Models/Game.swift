//
//  Game.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

class Game {
    var id: String!
    var userIsCreator: Bool!
    var userID: String!
    
    let questionsCount = Constants.GameSettings.questionsCount
    var questionsList: [String] = []
    var questionCurInd = 0
    
    var correctAnswersList: [String] = []
    var correctAnswerInd = 0
    
    let wrongAnswersCount = Constants.GameSettings.wrongAnswersCount
    var wrongAnswersList: [[String]] = []
    
    var userCorrectAnswersCount = 0
    
    
    init(id: String, userIsCreator: Bool, userID: String) {
        self.id = id
        self.userIsCreator = userIsCreator
        self.userID = userID
    }
    
    // Load lists of random questions, correct and wrong answers
    func loadData(completion: @escaping() -> Void) {
        let db = Firestore.firestore()

        db.collection("words").document("categories").getDocument { (snapshot, error) in

            guard error == nil && snapshot != nil else { return }

            // Get random category
            let categoriesList = snapshot!.data()!["list"] as! [String]

            let categoryInd = Int.random(in: 0 ..< categoriesList.count)
            let category = categoriesList[categoryInd]

            // Get lists of random words from this category
            db.collection("words").document(category).getDocument { (snapshot, error) in

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
                
                completion()
            }
        }
    }
    
}
