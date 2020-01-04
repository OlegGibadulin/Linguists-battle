//
//  UserManager.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

class GameContentManager {
    
    // Load list of games information
    func getGamesContentList(id gamesIDList: [String]) -> [GameContent] {
        
        let db = Firestore.firestore()
        var gamesContentList: [GameContent] = []
        
        for documnetID in gamesIDList {
            db.collection("games").document(documnetID).getDocument { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                if let gameData = snapshot!.data()! as [String:Any]? {
                    
                    let gameContent = self.getGameContent(from: gameData)
                    
                    gamesContentList.insert(gameContent, at: 0)
                }
            }
        }
        
        return gamesContentList
    }
    
    func getGameContent(from gameData: [String:Any]) -> GameContent {
        return GameContent(
            creatorNickname: gameData["creator_nickname"] as? String,
            creatorID: gameData["creator_uid"] as? String,
            creatorScore: gameData["creator_score"] as? Int,
            creatorGamesCount: gameData["creator_games_count"] as? Int,
            opponentNickname: gameData["opponent_nickname"] as? String,
            opponentID: gameData["opponent_uid"] as? String,
            opponentScore: gameData["opponent_score"] as? Int,
            opponentGamesCount: gameData["opponent_games_count"] as? Int,
            isCreatorTurn: gameData["is_creator_turn"] as? Bool)
    }
}
