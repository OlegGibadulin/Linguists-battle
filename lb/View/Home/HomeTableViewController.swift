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
    
    var viewModel: HomeViewModel! {
        didSet {
            viewModel.updateGamesList() {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var findGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        setUpElements()
        fillNicknameLabel()
    }
    
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        viewModel.updateGamesList() {
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(findGameButton)
    }
    
    // Set user nickname into label
    func fillNicknameLabel() {
        
        nicknameLabel.text = "Привет, " + viewModel.getNickname()
    }
    
    func showActivityIndicator() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.startAnimating();

        alert.view.addSubview(activityIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideActivityIndicator() {
        dismiss(animated: false, completion: nil)
    }
    
    // Transition to the game screen
    func goToGameScreen() {
        showActivityIndicator()
        
        guard tableView != nil && tableView!.indexPathForSelectedRow != nil else { return }

        let index = tableView!.indexPathForSelectedRow!
        
        self.tableView.deselectRow(at: index, animated: true)
        
        viewModel.increaseUserGameCount(at: index.row)
        
        let gameID = viewModel.getGameID(at: index.row)
        let isCreator = viewModel.isCreator(at: index.row)
        
        let game = Game(id: gameID, userIsCreator: isCreator)
        
        game.loadData() {
            let gameViewModel = GameViewModel(game: game)
            
            let gameViewController =  self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.gameViewController) as? GameViewController
            
            self.hideActivityIndicator()
            
            self.view.window?.rootViewController = gameViewController
            self.view.window?.makeKeyAndVisible()
            
            gameViewController!.viewModel = gameViewModel
        }
    }

    // Find new opponent for game
    @IBAction func findGameTapped(_ sender: Any) {
        showActivityIndicator()
        viewModel.findGame() {
            self.hideActivityIndicator()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.getGamesCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! HomeTableViewCell
        
        let index = indexPath.row
        
        // Set opponent nickname
        let opponentNickname = viewModel.getOpponentNickname(at: index)
        cell.setData(opponentNickname)
        
        // Set game status
        if viewModel.isGameOver(at: index) {
            if viewModel.isVictory(at: index) {
                cell.setVictoryStatus()
            } else {
                cell.setDefeatStatus()
            }
        } else {
            if viewModel.isUserTurn(at: index) {
                cell.setReadyStatus()
            } else {
                cell.setWaitingStatus()
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        goToGameScreen()
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

