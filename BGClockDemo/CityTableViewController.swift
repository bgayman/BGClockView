//
//  CityTableViewController.swift
//  Apple Watch
//
//  Created by Brad G. on 3/5/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

protocol CityTableDelegate {
    func didSaveTimeZoneLocations(timeZoneLocations:[TimeZoneLocation])
}

class CityTableViewController: UITableViewController,UISearchBarDelegate,UISearchDisplayDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.searchResultsCities?.count ?? 0
        }
        return self.cityArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.accessoryType = .None
        if tableView == self.searchDisplayController!.searchResultsTableView {
            let timeZoneName = searchResultsCities![indexPath.row].timeZoneName
            if self.saveTimeZoneLocations.indexOf({$0.timeZoneName == timeZoneName}) != nil {
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = searchResultsCities![indexPath.row].displayName
            return cell
        }
        let timeZoneName = cityArray[indexPath.row].timeZoneName
        if self.saveTimeZoneLocations.indexOf({$0.timeZoneName == timeZoneName}) != nil {
            cell.accessoryType = .Checkmark
        }
        cell.textLabel?.text = cityArray[indexPath.row].displayName

        return cell
    }
    
    override func   tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        if tableView == self.searchDisplayController!.searchResultsTableView {
            self.saveTimeZoneLocations.append(self.searchResultsCities![indexPath.row])
        }
        else
        {
            self.saveTimeZoneLocations.append(cityArray[indexPath.row])
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }
    
    func filterContentForSearchText(searchText: String) {
        self.searchResultsCities = self.cityArray.filter({( timeZoneLocation: TimeZoneLocation) -> Bool in
            return timeZoneLocation.displayName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: UIBarButtonItem) {
        self.delegate?.didSaveTimeZoneLocations(self.saveTimeZoneLocations)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
