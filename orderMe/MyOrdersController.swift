//
//  MyOrdersController.swift
//  orderMe
//
//  Created by Boris Gurtovyy on 6/4/16.
//  Copyright © 2016 Boris Gurtovoy. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class MyOrdersController: UIViewController {
    
    var orders: [Order] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        if SingletonStore.sharedInstance.user != nil {
            self.loadData()
            SingletonStore.sharedInstance.newOrder = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let loginLogoutButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        let facebookButton = UIBarButtonItem(customView: loginLogoutButton)
        self.navigationItem.setRightBarButton(facebookButton, animated: false)
        loginLogoutButton.delegate = self
        loginLogoutButton.layer.cornerRadius = loginLogoutButton.bounds.height / 2
        loginLogoutButton.clipsToBounds = true
        if SingletonStore.sharedInstance.user == nil {
            showAlertWithLoginFacebookOption()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
    navigationController?.navigationBar.layer.insertSublayer(CALayer().setGradient(navigationController: navigationController!), at: 1)
    }
    
    func loadData(){
        NetworkClient.getOrders { (orders, error) in
            if error != nil {
                return
            }
            if let myOrders = orders {
                self.orders = myOrders
                self.orders.reverse()
                self.tableView.reloadData()
            }
        }
        tableView.reloadData()
    }
    
    func showAlertWithLoginFacebookOption() {
        let alertController = UIAlertController(title: "You did not login", message: "You need to login for viewing your orders", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            self.tabBarController?.selectedIndex = 1
        }
        let toFacebookAction = UIAlertAction(title: "Login", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
            if let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "RootNaviVC") as? UINavigationController {
                self.present(LoginViewController, animated: true) {
                    SingletonStore.sharedInstance.user = nil
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(toFacebookAction)
        self.present(alertController, animated: true, completion:nil)
    }
}

extension CALayer {
    func setGradient(navigationController: UINavigationController) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [Constants.mainThemeColor.cgColor, Constants.secondaryThemeColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: -20.0, width: (navigationController.navigationBar.frame.size.width), height: (navigationController.navigationBar.frame.size.height) + 20)
        return gradient
    }
}

// Mark : UITableViewDataSource
extension MyOrdersController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyOrdersCell.identifier, for: indexPath) as? MyOrdersCell else { return UITableViewCell() }
        
        let order = orders[indexPath.row]
        if order.created != nil, order.sum != nil {
            cell.configureCell(with: order)
        }
        
        return cell
    }
    
}

extension MyOrdersController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
            case .success(_, _, _): self.loginToServerAfterFacebook()
            case .cancelled:        break
            case .failed(_):        break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        self.navigationController?.popToRootViewController(animated: true)
        if let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "RootNaviVC") as? UINavigationController {
            //self.navigationController?.viewControllers.removeAll()
            self.present(LoginViewController, animated: true) {
                SingletonStore.sharedInstance.user = nil
            }
        }
    }
    
    func loginToServerAfterFacebook() {
        guard let accessToken = AccessToken.current?.authenticationToken else { return }
        NetworkClient.login(accessToken: accessToken) { (user, error) in
            SingletonStore.sharedInstance.user = user
        }
    }
}

//MARK: NewOrderProtocol
extension MyOrdersController: NewOrderProtocol {
    func addNewOrder(order: Order) {
        self.orders.append(order)
        self.tableView.reloadData()
    }
}


