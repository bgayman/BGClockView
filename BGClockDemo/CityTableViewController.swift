//
//  CityTableViewController.swift
//  Apple Watch
//
//  Created by Brad G. on 3/5/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

protocol CityTableDelegate {
    func didSaveTimeZoneLocations(_ timeZoneLocations:[TimeZoneLocation])
}

class CityTableViewController: UITableViewController,UISearchBarDelegate,UISearchDisplayDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cityArray:[TimeZoneLocation]{
        get{
            return self.appDelegate.timeZoneManager.allTimeZones
        }
    }
    var saveTimeZoneLocations = [TimeZoneLocation]()
    var delegate:CityTableDelegate?
    var searchResultsCities:[TimeZoneLocation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.searchResultsCities?.count ?? 0
        }
        return self.cityArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.accessoryType = .none
        if tableView == self.searchDisplayController!.searchResultsTableView {
            let timeZoneName = searchResultsCities![indexPath.row].timeZoneName
            if self.saveTimeZoneLocations.index(where: {$0.timeZoneName == timeZoneName}) != nil {
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = searchResultsCities![indexPath.row].displayName
            return cell
        }
        let timeZoneName = cityArray[indexPath.row].timeZoneName
        if self.saveTimeZoneLocations.index(where: {$0.timeZoneName == timeZoneName}) != nil {
            cell.accessoryType = .checkmark
        }
        cell.textLabel?.text = cityArray[indexPath.row].displayName

        return cell
    }
    
    override func   tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        if tableView == self.searchDisplayController!.searchResultsTableView {
            self.saveTimeZoneLocations.append(self.searchResultsCities![indexPath.row])
        }
        else
        {
            self.saveTimeZoneLocations.append(cityArray[indexPath.row])
        }
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        self.searchResultsCities = self.cityArray.filter({( timeZoneLocation: TimeZoneLocation) -> Bool in
            return timeZoneLocation.displayName.lowercased().range(of: searchText.lowercased()) != nil
        })
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        self.delegate?.didSaveTimeZoneLocations(self.saveTimeZoneLocations)
        self.dismiss(animated: true, completion: nil)
    }
}
