//
//  ConnectionsTableViewController.swift
//  Giveth
//
//  Created by Jagsifat Makkar on 2022-01-24.
//

import UIKit

class ConnectionsTableViewController: UITableViewController {
    
    var connections : [Entity] = [Entity]()
    var loggedInEntity : Entity? = nil
    private let coreDBHelper = CoreDBHelper.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 125

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loggedInEntity = self.coreDBHelper.getEntityByName(UserDefaults.standard.string(forKey: "loggedInEntity") ?? "")
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchAllConnections()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.connections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionCell", for: indexPath) as! ConnectionCell
        
        cell.entityImage?.image = UIImage(named: self.connections[indexPath.row].images![1])
        cell.nameLabel?.text = self.connections[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: "donationModeIsOn"){
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let prepareCartVC = storyboard.instantiateViewController(identifier: "PrepareCart") as! PrepareCartViewController
            self.navigationController?.pushViewController(prepareCartVC, animated: true)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let entityDetailsVC = storyboard.instantiateViewController(identifier: "EntityDetails") as! EntityDetailsViewController
            entityDetailsVC.entity = self.connections[indexPath.row]
            self.navigationController?.pushViewController(entityDetailsVC, animated: true)
        }
    }
    
    private func fetchAllConnections(){
        self.connections.removeAll()
        for x in self.loggedInEntity?.connections ?? []{
            self.connections.append(self.coreDBHelper.getEntityByName(x)!)
        }
        self.tableView.reloadData()
    }


}
