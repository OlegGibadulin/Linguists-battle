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
    
    var nickname: String = ""
    var gamesIDList: [String] = []
    var gamesContentList: [[String:Any]] = []
    
    override func viewDidLoad() {
        db = Firestore.firestore()
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
                self.gamesIDList = games as! [String]
                
                self.loadGamesContent()
            }
        }
    }
    
    // Load list of games information
    func loadGamesContent() {
        
        for documnetID in self.gamesIDList {
            
            db.collection("games").document(documnetID).getDocument { (snapshot, error) in
                
                guard error == nil && snapshot != nil else { return }
                
                let gameContent = snapshot!.data()!
                
                self.gamesContentList.insert(gameContent, at: 0)
                
//                self.gamesContentList.append(gameContent)
                
                self.tableView.reloadData()
            }
        }
    }

    // Find new opponent for game
    @IBAction func findGameTapped(_ sender: Any) {
        
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return gamesContentList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! HomeTableViewCell
        
        // Set opponent nickname
        if isCreator(indexPath: indexPath) {
            cell.setData(gamesContentList[indexPath.row]["opponent_nickname"] as! String)
        }
        else {
            cell.setData(gamesContentList[indexPath.row]["creator_nickname"] as! String)
        }
        
        // Set game status
        if isGameOver(indexPath: indexPath) {
            
            if isVictory(indexPath: indexPath) {
                cell.setVictoryStatus()
            } else {
                cell.setDefeatStatus()
            }
            
        } else {
            
            if isUserTurn(indexPath: indexPath) {
                cell.setReadyStatus()
                print(indexPath.row)
                print("ready")
            } else {
                cell.setWaitingStatus()
                print(indexPath.row)
                print("wait")
            }
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "GamePage", sender: self)
    }

    // Transition to the game screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GamePage" {
            
            guard tableView != nil && tableView!.indexPathForSelectedRow != nil else { return }
            
            let controller = segue.destination as! GameViewController
            
            let index = tableView!.indexPathForSelectedRow!
            let gameID = self.gamesIDList[index.row]
            
            print(index.row, gameID, isCreator(indexPath: index), isUserTurn(indexPath: index))
            
            print(self.gamesIDList)
            
            controller.gameID = gameID
            
            controller.isCreator = isCreator(indexPath: index)
            
            if isCreator(indexPath: index) {
                self.db.collection("games").document(gameID).setData(["creator_games_count": 1, "is_creator_turn": false], merge: true)
            }
            else {
                self.db.collection("games").document(gameID).setData(["opponent_games_count": 1, "is_creator_turn": true], merge: true)
            }
            
            tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
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

