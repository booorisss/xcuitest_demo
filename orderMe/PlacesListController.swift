//
//  PlacesListController.swift
//  iOrder
//
//  Created by Boris Gurtovyy on 29.03.16.
//  Copyright © 2016 Boris Gurtovoy. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class PlacesListController: UIViewController, CLLocationManagerDelegate {
    
    fileprivate var places = [Place]()
    fileprivate var filteredPlaces = [Place]()
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var firstLocation = true
    fileprivate var lastLocation = CLLocation()
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var searchView: SearchView!
    fileprivate let searchViewHeight: CGFloat = 80.0
    fileprivate var searchText: String = ""
    
    fileprivate var userIsSearching: Bool {
        return self.searchView.searchField.isFirstResponder && self.searchText != ""
    }
    
    
    override func viewDidLoad() {
        
        self.initializeLocationManager()
        
        // async Places downloading
        self.getPlaces()
        
        self.tableView.dataSource = self
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.tableView.register(PlaceCell.self, forCellReuseIdentifier: "PlaceListCell")
        
        self.setupSearchView()
        self.searchView.searchResultsUpdater = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
        
        if SingletonStore.sharedInstance.qrCodeDetected {
            SingletonStore.sharedInstance.qrCodeDetected = false
            if let placeMainMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "PlaceMainMenu") as? PlaceMainMenuController {
                placeMainMenuVC.place = SingletonStore.sharedInstance.place
                self.navigationController?.pushViewController(placeMainMenuVC, animated: true)
            }
        } else {
            Bucket.sharedInstance.myBucket = [:]
            Bucket.sharedInstance.allSum = 0
            SingletonStore.sharedInstance.tableID = -1
        }
        
        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func initializeLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        }
    }

    fileprivate func setupSearchView() {
        self.searchView = SearchView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.searchViewHeight))
        self.view.addSubview(searchView)
        let tableViewEdgeInsets = UIEdgeInsets(top: self.searchViewHeight - 8.0, left: 0, bottom: 0, right: 0)
        self.tableView.contentInset = tableViewEdgeInsets
        self.tableView.scrollIndicatorInsets = tableViewEdgeInsets
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    // async getting Array of places from API
    fileprivate func getPlaces() {
        NetworkClient.getPlaces { (placesOpt, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let places = placesOpt else {
                return
            }
            self.places = places
            SingletonStore.sharedInstance.allplaces = self.places
            self.tableView.reloadData()
            NetworkClient.analytics(action: .placesListShown, info: "\(places.count) places")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? PlaceCell
        if let placeMenu = segue.destination as? PlaceMainMenuController {
            placeMenu.place = cell!.place
            SingletonStore.sharedInstance.place = cell!.place
            guard let id = cell?.place.id else {
                return
            }
            SingletonStore.sharedInstance.placeIdValidation = id
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            NetworkClient.analytics(action: .placeTapped, info: "\(id)")
        }
        
        if let qrCoder = segue.destination as? GetTableIdVC {
            qrCoder.noPlace = true
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let myLocation = locations.last
        
        // update only if user moved more than on 100
        if self.firstLocation || self.lastLocation.distance(from: myLocation!) > 100  {
            for place in self.places {
                guard let placeLatitude = place.latitude,
                    let placeLongitute = place.longitude else {
                        return
                }
                let lat1: NSString = placeLatitude as NSString
                let lng1: NSString = placeLongitute as NSString
                
                let latitute: CLLocationDegrees = lat1.doubleValue
                let longitute: CLLocationDegrees = lng1.doubleValue
                let placeLocation = CLLocation(latitude: latitute, longitude: longitute)
                let d = myLocation!.distance(from: placeLocation) / 1000
                place.distance = Double(round(10*d)/10)
                
                self.firstLocation = false
            }
            guard let myLoc = myLocation else { return }
            self.lastLocation = myLoc
            self.tableView.reloadData()
        }
    }
}


// MARK: UISearchResultsUpdating
extension PlacesListController: SearchViewDelegate {
    func userDidPressQRButton() {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "getTable") as? GetTableIdVC {
            controller.noPlace = true
            self.present(controller, animated: true, completion: nil)
        }
    }

    
    func updateSearchResults(for searchField: UITextField, text: String) {
        self.filterContentForSearchText(text)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.searchText = searchText
        self.filteredPlaces = places.filter { place in
            guard let name = place.name else {
                return false
            }
            return name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    func keyboardDismiss() {
        searchView.resignFirstResponder()
    }
}


// MARK: UITableViewDataSource
extension PlacesListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userIsSearching {
            return filteredPlaces.count
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.identifier, for: indexPath) as? PlaceCell {
            let place: Place!
            if userIsSearching {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            cell.configureCell(for: place)
            
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: Hide keyboard when tap somewhere on view
extension PlacesListController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlacesListController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
