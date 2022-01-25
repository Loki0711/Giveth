//
//  ViewController.swift
//  Giveth
//
//  Created by Jagsifat Makkar on 2022-01-23.
//

import UIKit
import AVFoundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    private let coreDBHelper = CoreDBHelper.getInstance()
    private var entityList = [Entity]()
    var playerLooper : AVPlayerLooper? = nil

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var rememberMeLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.coreDBHelper.preLoadData()
        self.titleImage.image = UIImage(named: "logo")
        self.displayVideo()
        self.emailTextField.layer.zPosition = 1
        self.rememberMeSwitch.layer.zPosition = 1
        self.passwordTextField.layer.zPosition = 1
        self.loginButton.layer.zPosition = 1
        self.rememberMeLabel.layer.zPosition = 1
        self.titleImage.layer.zPosition = 1
        if UserDefaults.standard.bool(forKey: "rememberMe"){
            self.login()
        }
    }
    
    private func displayVideo() {
        let player = AVQueuePlayer()
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        videoView.layer.addSublayer(layer)
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "login", ofType: "mp4")!))
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        player.volume = 0
        player.play()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let entity = self.coreDBHelper.validateLogin(self.emailTextField.text ?? "", self.passwordTextField.text ?? "")
        if entity == nil{
            let alert = UIAlertController(title: "Login Failed", message: "Invalid Credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            UserDefaults.standard.set(entity?.name, forKey: "loggedInEntity")
            self.login()
        }
    }
    
    private func login(){
        if rememberMeSwitch.isOn{
            UserDefaults.standard.set(true, forKey: "rememberMe")
        }
        else{
            UserDefaults.standard.set(false, forKey: "rememberMe")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let homeVC = storyboard.instantiateViewController(identifier: "HomePage") as! HomePageTableViewController
        homeVC.loggedInEntity = self.coreDBHelper.getEntityByName(UserDefaults.standard.string(forKey: "loggedInEntity") ?? "")
        
        let tabBarHomePageC = storyboard.instantiateViewController(withIdentifier: "TabBarHomePage")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabBarHomePageC)
    }
    
}

