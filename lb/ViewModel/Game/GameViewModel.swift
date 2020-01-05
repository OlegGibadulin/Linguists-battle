//
//  GameViewModel.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

class GameViewModel {
    var db: Firestore!
    
    var game: Game!
    
    required init(game: Game) {
        self.game = game
        
        db = Firestore.firestore()
    }
    
    // Save user score
    func saveUserScore() {
        if game.userIsCreator { self.db.collection("games").document(game.id).setData(["creator_score": game.userCorrectAnswersCount], merge: true)
        } else { self.db.collection("games").document(game.id).setData(["opponent_score": game.userCorrectAnswersCount], merge: true)
        }
    }
    
    func getCurQuestion() -> String {
        return game.questionsList[game.questionCurInd]
    }
    
    func createCorrectAnswerInd() -> Int {
        game.correctAnswerInd = Int.random(in: 0 ..< game.wrongAnswersCount + 1)
        
        return game.correctAnswerInd
    }
    
    func getCorrectAnswerInd() -> Int {
        return game.correctAnswerInd
    }
    
    func getCurAnswer() -> String {
        return game.correctAnswersList[game.questionCurInd]
    }
    
    func getCurWrongAnswer(at wrongAnswersInd: Int) -> String {
        return game.wrongAnswersList[game.questionCurInd][wrongAnswersInd]
    }
    
    func increaseUserScore() {
        game.userCorrectAnswersCount += 1
    }
    
    func decreaseUserScore() {
        game.userCorrectAnswersCount -= 1
    }
    
    func isGameOver() -> Bool {
        return game.questionCurInd == game.questionsCount - 1
    }
    
    func getUserResults() -> String {
        return " Правильно " + String(game.userCorrectAnswersCount) + " из " + String(game.questionsCount) + " "
    }
    
    func increaseQuestionIndex() {
        game.questionCurInd += 1
    }
    
}
