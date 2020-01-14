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
    
    func getUserID() -> String {
        return game.userID
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
    
    func getTranscription(word: String, completion: @escaping(String) -> Void) {
        
        let urlString = Constants.YandexDictionary.request + word
        
        guard let url = URL(string: urlString) else { return }
        
        // Get word translations, transcriptions
        // and examples from Yandex.Dictionary
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            let desc = String(data: data, encoding: .utf8)
            let arr = desc!.split(separator: "\"")
            var transcription = String()
            
            // Looking for transcription
            for i in 0 ..< arr.count {
                if arr[i] == "ts" {
                    transcription = String(arr[i + 2])
                    break
                }
            }
            
            completion(transcription)
        }.resume()
    }
    
}
