//
//  UserManager.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Foundation

class GameContentManager {
    
    // Load list of games information
    func getGamesContent(id gamesIDList: [String]) -> [gameContent] {
        
        let db = Firestore.firestore()
        gamesContentList: [gameContent] = []
        
        for documnetID in gamesIDList {
            db.collection("games").document(documnetID).getDocument { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                if let gc = snapshot!.data()! as! [String:Any]? {
                    
                    var gameContent = GameContent(
                        creatorNickname: gc["creator_nickname"],
                        creatorID: gc["creator_uid"],
                        creatorScore: gc["creator_score"],
                        creatorGamesCount: gc["creator_games_count"],
                        opponentNickname: gc["opponent_nickname"],
                        opponentID: gc["opponent_uid"],
                        opponentScore: gc["opponent_score"],
                        opponentGamesCount: gc["opponent_games_count"],
                        isCreatorTurn: gc["is_creator_turn"])
                    
                    gamesContentList.insert(gameContent, at: 0)
                }
            }
        }
        
        return
    }
}
