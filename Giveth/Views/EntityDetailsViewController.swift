//
//  EntityDetailsViewController.swift
//  Giveth
//
//  Created by Jagsifat Makkar on 2022-01-23.
//

import UIKit

class EntityDetailsViewController: UIViewController {
    
    var entity : Entity? = nil
    var loggedInEntity : Entity? = nil
    @IBOutlet weak var connectButton: UIButton!
    private let coreDBHelper = CoreDBHelper.getInstance()
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if entity?.type == "charity"{
            self.loadCharityVC()
        } else {
            self.loadResVC()
        }
        
    }
    
    func loadCharityVC(){
        let charityVC  = storyboard?.instantiateViewController(withIdentifier: "CharityVC") as! CharityDetailsViewController
        charityVC.entity = entity
        self.addChild(charityVC)
        charityVC.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview(charityVC.view)
        charityVC.didMove(toParent: self)
    }
    
    func loadResVC(){
        let resVC  = storyboard?.instantiateViewController(withIdentifier: "RestaurantVC") as! RestaurantDetailsViewController
        resVC.entity = entity
        self.addChild(resVC)
        resVC.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
        self.containerView.addSubview(resVC.view)
        resVC.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loggedInEntity = self.coreDBHelper.getEntityByName(UserDefaults.standard.string(forKey: "loggedInEntity") ?? "")
        if Bool(self.entity?.connectionRequests?.contains(self.loggedInEntity?.name ?? "") ?? false)  {
            self.connectButton.setTitle("Cancel Request", for: .normal)
        }
        else if Bool(self.entity?.connections?.contains(self.loggedInEntity?.name ?? "") ?? false){
            self.connectButton.setTitle("Disconnect", for: .normal)
        }
    }

    @IBAction func connectPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Connect"{
            self.coreDBHelper.updateEntityConnectionRequests(loggedInEntity?.name ?? "", entity?.name ?? "")
            sender.setTitle("Cancel Request", for: .normal)
        }
        else if sender.titleLabel?.text == "Disconnect"{
            self.coreDBHelper.deleteConnection(self.loggedInEntity?.name ?? "", entity?.name ?? "")
            sender.setTitle("Connect", for: .normal)
        }
        else{
            self.coreDBHelper.deleteConnectionRequest(self.loggedInEntity?.name ?? "", entity?.name ?? "")
            sender.setTitle("Connect", for: .normal)
        }
    }
    
    
    
}
