//
//  ConnectionRequestsTableViewController.swift
//  Giveth
//
//  Created by Jagsifat Makkar on 2022-01-23.
//

import UIKit

class ConnectionRequestsTableViewController: UITableViewController {
    
    var loggedInEntity : Entity? = nil
    private let coreDBHelper = CoreDBHelper.getInstance()
    var requestsList = [Entity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 125
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loggedInEntity = self.coreDBHelper.getEntityByName(UserDefaults.standard.string(forKey: "loggedInEntity") ?? "")
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchAllConnectionRequests()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.requestsList.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //delete the task
        if (editingStyle == UITableViewCell.EditingStyle.delete && indexPath.row < self.requestsList.count){
            //ask for the user confirmation
            self.deleteRequestFromList(indexPath: indexPath)
        }
    }
    
    private func deleteRequestFromList(indexPath : IndexPath){
        self.coreDBHelper.deleteConnectionRequest(self.requestsList[indexPath.row].name ?? "", self.loggedInEntity?.name ?? "")
        self.fetchAllConnectionRequests()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionRequestCell", for: indexPath) as! ConnectionRequestCell
        
        cell.nameLabel.text = self.requestsList[indexPath.row].name
        cell.entityImage.image = UIImage(named: self.requestsList[indexPath.row].images![1])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Connection Request", message: "How would you like to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "View Profile", style: .default, handler: { UIAlertAction in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let entityDetailsVC = storyboard.instantiateViewController(identifier: "EntityDetails") as! EntityDetailsViewController
            entityDetailsVC.entity = self.requestsList[indexPath.row]
            self.navigationController?.pushViewController(entityDetailsVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Accept Request", style: .default, handler: { UIAlertAction in
            self.coreDBHelper.updateEntitiesConnections(self.requestsList[indexPath.row].name ?? "", self.loggedInEntity?.name ?? "")
            self.deleteRequestFromList(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Decline Request", style: .default, handler: { UIAlertAction in
            self.deleteRequestFromList(indexPath: indexPath)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchAllConnectionRequests(){
        self.requestsList.removeAll()
        for x in self.loggedInEntity?.connectionRequests ?? []{
            self.requestsList.append(self.coreDBHelper.getEntityByName(x)!)
        }
        self.tableView.reloadData()
    }
}
