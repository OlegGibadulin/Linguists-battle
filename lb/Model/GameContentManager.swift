//
//  UserManager.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Foundation

class UserManager {
    var db: Firestore!
    
    // Load list of games information
    func loadGamesContent() {
        
        for documnetID in self.gamesIDList {
            db.collection("games").document(documnetID).getDocument { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                let gameContent = snapshot!.data()!
                
                self.gamesContentList.insert(gameContent, at: 0)
                
                self.tableView.reloadData()
            }
        }
    }
}
