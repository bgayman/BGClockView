//
//  CustomizeClockSettingsTableViewController.swift
//  BGClockDemo
//
//  Created by Brad G. on 4/9/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

class CustomizeClockSettingsTableViewController: UITableViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let title = cell?.textLabel?.text
        if indexPath.section == 0
        {
            NSUserDefaults.standardUserDefaults().setObject(title, forKey: "customizeFaceStyle")
        }
        else if indexPath.section == 1
        {
            NSUserDefaults.standardUserDefaults().setObject(title, forKey: "customizeHandStyle")
        }
        else if indexPath.section == 2
        {
            NSUserDefaults.standardUserDefaults().setObject(title, forKey: "customizeFont")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let faceStyle = NSUserDefaults.standardUserDefaults().objectForKey("customizeFaceStyle") as? String
        let handStyle = NSUserDefaults.standardUserDefaults().objectForKey("customizeHandStyle") as? String
        let font = NSUserDefaults.standardUserDefaults().objectForKey("customizeFont") as? String
        switch indexPath.section {
        case 0:
            let title = cell.textLabel!.text
            if title == faceStyle
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
        case 1:
            let title = cell.textLabel!.text
            if title == handStyle
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
            break
        case 2:
            let title = cell.textLabel!.text
            if title == font
            {
                cell.accessoryType = .Checkmark
            }
            else if font == nil && title == ".SFUIText-Regular"
            {
                cell.accessoryType = .Checkmark
            }
            else
            {
                cell.accessoryType = .None
            }
            break
        case 3:
            cell.accessoryType = .DisclosureIndicator
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("Minute Tick Color") as? String
            {
                cell.textLabel?.text = title.capitalizedString
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 4:
            cell.accessoryType = .DisclosureIndicator
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("Second Tick Color") as? String
            {
                cell.textLabel?.text = title.capitalizedString
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 5:
            cell.accessoryType = .DisclosureIndicator
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("Text Color") as? String
            {
                cell.textLabel?.text = title.capitalizedString
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 6:
            cell.accessoryType = .DisclosureIndicator
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("Hour Hand Color") as? String
            {
                cell.textLabel?.text = title.capitalizedString
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 7:
            cell.accessoryType = .DisclosureIndicator
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("Minute Hand Color") as? String
            {
                cell.textLabel?.text = title.capitalizedString
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 8:
            cell.accessoryType = .DisclosureIndicator
            if let title = NSUserDefaults.standardUserDefaults().objectForKey("Second Hand Color") as? String
            {
                cell.textLabel?.text = title.capitalizedString
            }
            else
            {
                cell.textLabel?.text = "Red"
            }
            break
        case 9:
            if (NSUserDefaults.standardUserDefaults().objectForKey((cell.textLabel?.text)!) != nil) {
                let isOn = NSUserDefaults.standardUserDefaults().boolForKey((cell.textLabel?.text)!)
                if let switchView = cell.accessoryView as? UISwitch
                {
                    switchView.on = isOn
                }
                
            }
            break
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell
        {
            let indexPath = self.tableView.indexPathForCell(cell)
            if let colorVC = segue.destinationViewController as? CustomizeColorTableViewController
            {
                if indexPath?.section == 3
                {
                    colorVC.userDefaultColorKey = "Minute Tick Color"
                    colorVC.navigationItem.title = "Minute Tick Color"
                }
                if indexPath?.section == 4
                {
                    colorVC.userDefaultColorKey = "Second Tick Color"
                    colorVC.navigationItem.title = "Second Tick Color"
                }
                if indexPath?.section == 5
                {
                    colorVC.userDefaultColorKey = "Text Color"
                    colorVC.navigationItem.title = "Text Color"
                }
                if indexPath?.section == 6
                {
                    colorVC.userDefaultColorKey = "Hour Hand Color"
                    colorVC.navigationItem.title = "Hour Hand Color"
                }
                if indexPath?.section == 7
                {
                    colorVC.userDefaultColorKey = "Minute Hand Color"
                    colorVC.navigationItem.title = "Minute Hand Color"
                }
                if indexPath?.section == 8
                {
                    colorVC.userDefaultColorKey = "Second Hand Color"
                    colorVC.navigationItem.title = "Second Hand Color"
                }
            }
            
        }
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        let location = self.tableView.convertPoint(sender.bounds.origin, fromView: sender)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: (cell!.textLabel?.text)!)
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    @IBAction func done(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
