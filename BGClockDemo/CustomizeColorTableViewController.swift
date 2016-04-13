//
//  CustomizeColorTableViewController.swift
//  BGClockDemo
//
//  Created by Brad G. on 4/10/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

class CustomizeColorTableViewController: UITableViewController {
    var userDefaultColorKey:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BGClockView.colorDictionary().keys.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let color = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultColorKey!) as? String
        
        let colorStrings:[String] = [String](BGClockView.colorDictionary().keys)
        let title = colorStrings[indexPath.row]
        cell.textLabel?.text = title.capitalizedString
        
        if title == color || (color == nil && title == "black" && self.navigationItem.title != "Second Hand Color") || (color == nil && title == "red" && self.navigationItem.title == "Second Hand Color")
        {
            cell.accessoryType = .Checkmark
        }
        else
        {
            cell.accessoryType = .None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let colorStrings:[String] = [String](BGClockView.colorDictionary().keys)
        let color = colorStrings[indexPath.row]
        NSUserDefaults.standardUserDefaults().setObject(color, forKey: userDefaultColorKey!)
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Colors"
    }

}
