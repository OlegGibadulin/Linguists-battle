//
//  HomeTableViewController.swift
//  lb
//
//  Created by Mac-HOME on 17.12.2019.
//  Copyright © 2019 Mac-HOME. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UITableViewController {
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var findGameButton: UIButton!
    
    var db: Firestore!
    var gamesList: [[String:Any]] = []
    var nickname: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        db = Firestore.firestore()
        
        setUpElements()
        fillNicknameLabel()
        loadGamesList()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(findGameButton)
    }
    
    // Set user nickname into label
    func fillNicknameLabel() {
        
        db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let userData = snapshot!.documents[0].data()
            
            if let nickname = userData["nickname"] {
                self.nicknameLabel.text = "Hello, " + (nickname as! String)
                self.nickname = nickname as! String
            }
        }
    }
    
    // Load list of current games of user
    func loadGamesList() {
        db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let userData = snapshot!.documents[0].data()
            
            if let games = userData["games"] {
                self.gamesList = games as! [[String:Any]]
                
                self.tableView.reloadData()
            }
        }
    }

    // Find new opponent for game
    @IBAction func findGameTapped(_ sender: Any) {
        
        // Looking for new opponent
        db.collection("users").getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            var opponent: [String:Any] = ["nickname":"", "uid":""]
            var opponentInd = 0
            var opponentData: [String:Any] = [:]
            var isNotFounded = true
            
            while isNotFounded {
                isNotFounded = false
                
                // Get random opponent
                opponentInd = Int.random(in: 0 ..< snapshot!.documents.count)
                opponentData = snapshot!.documents[opponentInd].data()
                
                opponent["nickname"] = opponentData["nickname"] as! String
                opponent["uid"] = opponentData["uid"] as! String
                
                // Check for user
                if opponent["uid"] as! String == Constants.User.id! {
                    isNotFounded = true
                    continue
                }
                
                // Check for repeated opponent
                for curUserOpponent in self.gamesList {
                    if opponent["uid"] as! String == curUserOpponent["uid"] as! String {
                        isNotFounded = true
                        break
                    }
                }
            }
            
            // Add user ID to opponent list of games
            if var games = opponentData["games"] as! [[String:Any]]? {
                let document = snapshot!.documents[opponentInd]
                    
                games.append(["nickname": self.nickname, "uid": Constants.User.id!])
            self.db.collection("users").document(document.documentID).setData(["games" : games], merge: true)
            }
            
            // Add opponent ID to user list of games
            self.gamesList.append(opponent)
            
            self.db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                let document = snapshot!.documents[0]
            self.db.collection("users").document(document.documentID).setData(["games" : self.gamesList], merge: true)
                
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return gamesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! HomeTableViewCell
        
        cell.setData(gamesList[indexPath.row]["nickname"] as! String)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

