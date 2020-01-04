//
//  HomeViewModel.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

class HomeViewModel {
    var user: User!
    var gamesContentList: [GameContent] = []
    
    init() {
        db = Firestore.firestore()
    }
    
    // Check if user is creator
    func isCreator(indexPath: IndexPath) -> Bool {
        let creatorID = gamesContentList[indexPath.row]["creator_uid"] as! String
        
        return creatorID == Constants.User.id!
    }
    
    // Check for user turn
    func isUserTurn(indexPath: IndexPath) -> Bool {
        let isCreatorTurn = gamesContentList[indexPath.row]["is_creator_turn"] as! Bool
        
        return isCreator(indexPath: indexPath) == isCreatorTurn
    }
    
    // Check for needed count of games
    func isGameOver(indexPath: IndexPath) -> Bool {
        let creatorGamesCount = gamesContentList[indexPath.row]["creator_games_count"] as! Int
        
        let opponentGamesCount = gamesContentList[indexPath.row]["opponent_games_count"] as! Int
        
        return creatorGamesCount == Constants.GameSettings.gameCount && opponentGamesCount == Constants.GameSettings.gameCount
    }
    
    // Check for game score
    func isVictory(indexPath: IndexPath) -> Bool {
        let creatorScore = gamesContentList[indexPath.row]["creator_score"] as! Int
        
        let opponentScore = gamesContentList[indexPath.row]["opponent_score"] as! Int
        
        let creatorScoreIsBigger = creatorScore > opponentScore
        
        return isCreator(indexPath: indexPath) == creatorScoreIsBigger
    }
    
    func getOpponentNickname() {
        if isCreator(indexPath: indexPath) {
            cell.setData(gamesContentList[indexPath.row]["opponent_nickname"] as! String)
        }
        else {
            cell.setData(gamesContentList[indexPath.row]["creator_nickname"] as! String)
        }
    }
    
    func increaseUserGameCount() {
        if isCreator(indexPath: index) {
            self.db.collection("games").document(gameID).setData(["creator_games_count": 1, "is_creator_turn": false], merge: true)
        }
        else {
            self.db.collection("games").document(gameID).setData(["opponent_games_count": 1, "is_creator_turn": true], merge: true)
        }
    }
    
    // Find new opponent for game
    func findGame() {
            
            // Queue of created games that are waiting for opponent
            let createdGames = db.collection("queue_for_game").document("created_games")
            
            createdGames.getDocument { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                var gamesID = snapshot!.data()!["games_id"] as! [String]
                
                var foundGameInd = 0
                var gameIsFound = false
                
                // Check for relevant game
                for ind in 0 ..< gamesID.count {
                    if !self.gamesIDList.contains(gamesID[ind]) {
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
                    self.gamesIDList.insert(foundGameID, at: 0)
    //                self.gamesIDList.append(foundGameID)
                    
                    self.db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
                        
                        guard error == nil && snapshot != nil else { return }
                        
                        let document = snapshot!.documents[0]
                    self.db.collection("users").document(document.documentID).setData(["games" : self.gamesIDList], merge: true)
                    }
                    
                    // Update content of founded game
                    let foundGame = self.db.collection("games").document(foundGameID)
                    
                    foundGame.getDocument { (snapshot, error) in
                        
                        guard error == nil && snapshot != nil else { return }
                        
                        var gameContent = snapshot!.data()!
                        
                        gameContent["opponent_nickname"] = self.nickname
                        gameContent["opponent_uid"] = Constants.User.id!
                        
                        self.db.collection("games").document(foundGameID).setData(gameContent, merge: true)
                        
                        self.gamesContentList.insert(gameContent, at: 0)
                        
                        self.tableView.reloadData()
                    }
                }
                else {
                    // Create new game
                    let newGame = self.db.collection("games").document()
                    let newGameID = newGame.documentID
                    
                    // Update queue of games
                    gamesID.append(newGameID)
                    
                    createdGames.setData(["games_id" : gamesID], merge: true)
                    
                    // Update user's list of games id
                    self.gamesIDList.insert(newGameID, at: 0)
    //                self.gamesIDList.append(newGameID)
                    
                    self.db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
                        
                        guard error == nil && snapshot != nil else { return }
                        
                        let document = snapshot!.documents[0]
                    self.db.collection("users").document(document.documentID).setData(["games" : self.gamesIDList], merge: true)
                    }
                    
                    // Create content of new game
                    let newGameContent = ["creator_nickname": self.nickname, "creator_uid": Constants.User.id!, "creator_score": 0, "creator_games_count": 0, "opponent_nickname": "Waiting for opponent", "opponent_uid": "", "opponent_score": 0, "opponent_games_count": 0, "is_creator_turn": true] as [String : Any]
                    
                    self.db.collection("games").document(newGameID).setData(newGameContent, merge: true)
                    
                    self.gamesContentList.insert(newGameContent, at: 0)
                    
                    self.tableView.reloadData()
                }
            }
        }
    
}
