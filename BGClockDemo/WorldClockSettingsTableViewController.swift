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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = self.tableView.cellForRow(at: indexPath)
        let title = cell?.textLabel?.text
        if indexPath.section == 0
        {
            UserDefaults.standard.set(title, forKey: "faceStyle")
        }
        else if indexPath.section == 1
        {
            UserDefaults.standard.set(title, forKey: "handStyle")
        }
        UserDefaults.standard.synchronize()
        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let faceStyle = UserDefaults.standard.object(forKey: "faceStyle") as? String
        let handStyle = UserDefaults.standard.object(forKey: "handStyle") as? String
        
        if indexPath.section == 0
        {
            let title = cell.textLabel!.text
            if title != nil && title == faceStyle
            {
                cell.accessoryType = .checkmark
            }
            else if faceStyle == nil && title == ".Swiss"
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
        }
        else if indexPath.section == 1
        {
            let title = cell.textLabel!.text
            if title != nil && title == handStyle
            {
                cell.accessoryType = .checkmark
            }
            else if handStyle == nil && title == ".Swiss"
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
        }
    }

   
    @IBAction func done(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }

}
