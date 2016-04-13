//
//  WorldClockSettingsTableViewController.swift
//  BGClockDemo
//
//  Created by Brad G. on 3/16/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

class WorldClockSettingsTableViewController: UITableViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let title = cell?.textLabel?.text
        if indexPath.section == 0
        {
            NSUserDefaults.standardUserDefaults().setObject(title, forKey: "faceStyle")
        }
        else if indexPath.section == 1
        {
            NSUserDefaults.standardUserDefaults().setObject(title, forKey: "handStyle")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let faceStyle = NSUserDefaults.standardUserDefaults().objectForKey("faceStyle") as? String
        let handStyle = NSUserDefaults.standardUserDefaults().objectForKey("handStyle") as? String
        
        if indexPath.section == 0
        {
            let title = cell.textLabel!.text
            if title != nil && title == faceStyle
            {
                cell.accessoryType = .Checkmark
            }
            else if faceStyle == nil && title == ".Swiss"
            {
                cell.accessoryType = .Checkmark
            }
            else
            {
                cell.accessoryType = .None
            }
        }
        else if indexPath.section == 1
        {
            let title = cell.textLabel!.text
            if title != nil && title == handStyle
            {
                cell.accessoryType = .Checkmark
            }
            else if handStyle == nil && title == ".Swiss"
            {
                cell.accessoryType = .Checkmark
            }
            else
            {
                cell.accessoryType = .None
            }
        }
    }

   
    @IBAction func done(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
