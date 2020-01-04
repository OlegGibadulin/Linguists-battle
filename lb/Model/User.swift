//
//  User.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

struct User {
    var id: String!
    var nickname: String!
    var gamesIDList: [String] = []
    
    init(uid: String) {
        id = uid
        
        loadNickname()
        loadGamesList()
    }
    
    // Load user nickname
    func loadNickname() {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let userData = snapshot!.documents[0].data()
            
            if let nickname = userData["nickname"] as! String? {
                self.nickname = nickname
            }
        }
    }
    
    // Load list of current games of user
    func loadGamesList() {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let userData = snapshot!.documents[0].data()
            
            if let idList = userData["games"] as! [String]? {
                self.gamesIDList = idList
            }
        }
    }
    
}
