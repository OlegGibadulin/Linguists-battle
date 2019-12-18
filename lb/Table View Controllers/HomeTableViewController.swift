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
    var gamesList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        db = Firestore.firestore()
        
        setUpElements()
        fillNicknameLabel()
        loadData()
    }
    
    func setUpElements() {
        Utilities.styleFilledButton(findGameButton)
    }
    
    // Set user nickname into label
    func fillNicknameLabel() {
        
        db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let documentData = snapshot!.documents[0].data()
            
            if let nickname = documentData["nickname"] {
                self.nicknameLabel.text = "Hello, " + (nickname as! String)
            }
        }
    }
    
    func loadData() {
        db.collection("users").whereField("uid", isEqualTo: Constants.User.id!).getDocuments { (snapshot, error) in
            
            guard error == nil && snapshot != nil else { return }
            
            let documentData = snapshot!.documents[0].data()
            
            if let games = documentData["games"] {
                self.gamesList = games as! [String]
                
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func findGameTapped(_ sender: Any) {
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
        
        cell.setData(gamesList[indexPath.row])

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
