//
//  User.swift
//  lb
//
//  Created by Mac-HOME on 04.01.2020.
//  Copyright © 2020 Mac-HOME. All rights reserved.
//

import Firebase

class User {
    public var id: String!
    public var nickname: String!
    public var gamesIDList: [String] = []
    
    init(uid: String) {
        id = uid
    }
    
    // Load user nickname and list of current games of user
    func loadUserData(completion: @escaping() -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("uid", isEqualTo: id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let userData = snapshot!.documents[0].data()
            
            if let nickname = userData["nickname"] as! String? {
                self.nickname = nickname
            }
            
            if let idList = userData["games"] as! [String]? {
                self.gamesIDList = idList
            }
            
            completion()
        }
    }
    
}
