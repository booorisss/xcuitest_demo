//
//  LoginViewController.swift
//  orderMe
//
//  Created by Boris Gurtovyy on 12/30/16.
//  Copyright © 2016 Boris Gurtovoy. All rights reserved.
//

import UIKit

import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginToFacebook: UIButton!
    @IBOutlet weak var loginLaterButton: UIButton!
    
    var cameFromReserveOrOrderProcess = false
    
    private let loginManager: LoginManager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginToFacebook.accessibilityIdentifier = AccessibilityIdentifiers.LoginScreen.loginToFacebook
        loginLaterButton.accessibilityIdentifier = AccessibilityIdentifiers.LoginScreen.loginLaterButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loginLaterButton.layer.insertSublayer(view.themeGradient(), at: 0)
        
        self.navigationController?.isNavigationBarHidden = true
        AccessToken.refreshCurrentToken { (accessToken, error) in
            if AccessToken.current != nil {
                self.loginToServerAfterFacebook()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func continueWithFacebook() {
        self.loginManager.logOut()
        self.loginButtonClicked()
    }
    
    @IBAction func logInLaterButton() {
        self.successLogin()
        NetworkClient.analytics(action: .loginLaterTapped)
    }
    
    fileprivate func loginToServerAfterFacebook() {
        guard let accessToken = AccessToken.current?.authenticationToken else { return }
        NetworkClient.login(accessToken: accessToken) { (user, error) in
            if let error = error { 
                self.errorAlert(error)
                return
            }
            SingletonStore.sharedInstance.user = user
            print("APP TOKEN: " + (user?.token ?? "HUUHUH"))
            print("FACEBOOK TOKEN: " + (AccessToken.current?.authenticationToken ?? "HUHUHUHUH"))
            self.successLogin()
        }
        NetworkClient.analytics(action: .facebookTapped)
    }
    
    fileprivate func loginButtonClicked() {
        self.loginManager.loginBehavior = .native
        self.loginManager.logIn(readPermissions: [.email, .publicProfile],
                                viewController: self) { result in
                                    switch result {
                                    case .success(_, _, _):
                                        self.loginToServerAfterFacebook()
                                    case .cancelled:         break
                                    case .failed(let error): self.errorAlert(error as NSError)
                                    }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK : results of login
extension LoginViewController {
    func errorAlert(_ error: NSError? = nil) {
        let alertController = UIAlertController(title: "Error", message: "Sorry, some error occured. Try again later. " + (error?.description ?? ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func successLogin() {
        switch cameFromReserveOrOrderProcess {
        case false:
            if let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBar") as? MyTabBarController {
                mainTabBarController.selectedIndex = 1
                present(mainTabBarController, animated: false, completion: nil)
            }
        case true:
            self.cameFromReserveOrOrderProcess = false
            self.navigationController?.popViewController(animated: true)
        }
    }
}
