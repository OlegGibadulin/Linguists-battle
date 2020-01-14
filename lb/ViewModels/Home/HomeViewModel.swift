//
//  HomeViewModel.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

class HomeViewModel {
    var db: Firestore!
    
    var user: User!
    var gameContentManager: GameContentManager!
    var gamesContentList: [GameContent] = []
    
    required init(user: User, gameContentManager: GameContentManager) {
        self.user = user
        self.gameContentManager = gameContentManager
        
        db = Firestore.firestore()
    }
    
    func updateGamesList(completion: @escaping() -> Void) {
        
        self.gameContentManager.getGamesContentList(id: self.user.gamesIDList) { gamesContent in
            
            self.gamesContentList = gamesContent
            
            completion()
        }
    }
    
    func getUserNickname() -> String {
        return user.nickname
    }
    
    func getGamesCount() -> Int {
        return gamesContentList.count
    }
    
    // Check if user is creator
    func isCreator(at index: Int) -> Bool {
        let creatorID = gamesContentList[index].creatorID!
        
        return creatorID == user.id!
    }
    
    // Check for user turn
    func isUserTurn(at index: Int) -> Bool {
        let isCreatorTurn = gamesContentList[index].isCreatorTurn!
        
        return isCreator(at: index) == isCreatorTurn
    }
    
    // Check for needed count of games
    func isGameOver(at index: Int) -> Bool {
        let creatorGamesCount = gamesContentList[index].creatorGamesCount!
        let opponentGamesCount = gamesContentList[index].opponentGamesCount!
        
        return creatorGamesCount == Constants.GameSettings.gameCount && opponentGamesCount == Constants.GameSettings.gameCount
    }
    
    // Check for game score
    func isVictory(at index: Int) -> Bool {
        let creatorScore = gamesContentList[index].creatorScore!
        let opponentScore = gamesContentList[index].opponentScore!
        
        let creatorScoreIsBigger = creatorScore > opponentScore
        
        return isCreator(at: index) == creatorScoreIsBigger
    }
    
    func getOpponentNickname(at index: Int) -> String {
        
        var opponentNickname = ""
        
        if isCreator(at: index) {
            opponentNickname = gamesContentList[index].opponentNickname!
        } else {
            opponentNickname = gamesContentList[index].creatorNickname!
        }
        
        return opponentNickname
    }
    
    func getGameID(at index: Int) -> String {
        return user.gamesIDList[index]
    }
    
    func getUserID() -> String {
        return user.id
    }
    
    func increaseUserGameCount(at index: Int) {
        
        let gameID = getGameID(at: index)
        
        if isCreator(at: index) {
            self.db.collection("games").document(gameID).setData(["creator_games_count": 1, "is_creator_turn": false], merge: true)
        } else {
            self.db.collection("games").document(gameID).setData(["opponent_games_count": 1, "is_creator_turn": true], merge: true)
        }
    }
    
    // Find new opponent for game
    func findGame(completion: @escaping() -> Void) {
        
        // Queue of created games that are waiting for opponent
        let createdGames = db.collection("queue_for_game").document("created_games")
        
        createdGames.getDocument { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            var gamesID = snapshot!.data()!["games_id"] as! [String]
            
            var foundGameInd = 0
            var gameIsFound = false
            
            // Check for relevant game
            for ind in 0 ..< gamesID.count {
                if !self.user.gamesIDList.contains(gamesID[ind]) {
                    foundGameInd = ind
                    gameIsFound = true
                    break
                }
            }
            
            // Relevant game is found
            if gameIsFound {
                let foundGameID = gamesID[foundGameInd]
                
                // Update queue of games
                gamesID.remove(at: foundGameInd)
                
                createdGames.setData(["games_id" : gamesID], merge: true)
                
                // Update list of games id
                self.user.gamesIDList.insert(foundGameID, at: 0)
                
                self.db.collection("users").whereField("uid", isEqualTo: self.getUserID()).getDocuments { (snapshot, error) in
                    
                    guard error == nil && snapshot != nil else { return }
                    
                    let document = snapshot!.documents[0]
                    self.db.collection("users").document(document.documentID).setData(["games" : self.user.gamesIDList], merge: true)
                    
                }
                
                // Update content of founded game
                let foundGame = self.db.collection("games").document(foundGameID)
                
                foundGame.getDocument { (snapshot, error) in
                    
                    guard error == nil && snapshot != nil else { return }
                    
                    var gameData = snapshot!.data()!
                    
                    gameData["opponent_nickname"] = self.user.nickname
                    gameData["opponent_uid"] = self.getUserID()
                    self.db.collection("games").document(foundGameID).setData(gameData, merge: true)
                    
                    let gameContent = self.gameContentManager.getGameContent(from: gameData)
                    
                    self.gamesContentList.insert(gameContent, at: 0)
                    
                    completion()
                }
                
            } else {
                
                // Create new game
                let newGame = self.db.collection("games").document()
                let newGameID = newGame.documentID
                
                // Update queue of games
                gamesID.append(newGameID)
                
                createdGames.setData(["games_id" : gamesID], merge: true)
                
                // Update user's list of games id
                self.user.gamesIDList.insert(newGameID, at: 0)
                
                self.db.collection("users").whereField("uid", isEqualTo: self.getUserID()).getDocuments { (snapshot, error) in
                    
                    guard error == nil && snapshot != nil else { return }
                    
                    let document = snapshot!.documents[0]
                    self.db.collection("users").document(document.documentID).setData(["games" : self.user.gamesIDList], merge: true)
                    }
                
                // Create content of new game
                let newGameData = ["creator_nickname": self.user.nickname!, "creator_uid": self.getUserID(), "creator_score": 0, "creator_games_count": 0, "opponent_nickname": "Waiting for opponent", "opponent_uid": "", "opponent_score": 0, "opponent_games_count": 0, "is_creator_turn": true] as [String : Any]
                self.db.collection("games").document(newGameID).setData(newGameData, merge: true)
                
                let gameContent = self.gameContentManager.getGameContent(from: newGameData)
                
                self.gamesContentList.insert(gameContent, at: 0)
                
                completion()
                
            }
        }
    }
    
}
