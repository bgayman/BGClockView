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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = self.tableView.cellForRow(at: indexPath)
        let title = cell?.textLabel?.text
        if indexPath.section == 0
        {
            UserDefaults.standard.set(title, forKey: "customizeFaceStyle")
        }
        else if indexPath.section == 1
        {
            UserDefaults.standard.set(title, forKey: "customizeHandStyle")
        }
        else if indexPath.section == 2
        {
            UserDefaults.standard.set(title, forKey: "customizeFont")
        }
        UserDefaults.standard.synchronize()
        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let faceStyle = UserDefaults.standard.object(forKey: "customizeFaceStyle") as? String
        let handStyle = UserDefaults.standard.object(forKey: "customizeHandStyle") as? String
        let font = UserDefaults.standard.object(forKey: "customizeFont") as? String
        switch indexPath.section {
        case 0:
            let title = cell.textLabel!.text
            if title == faceStyle
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
        case 1:
            let title = cell.textLabel!.text
            if title == handStyle
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
            break
        case 2:
            let title = cell.textLabel!.text
            if title == font
            {
                cell.accessoryType = .checkmark
            }
            else if font == nil && title == ".SFUIText-Regular"
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
            break
        case 3:
            cell.accessoryType = .disclosureIndicator
            if let title = UserDefaults.standard.object(forKey: "Minute Tick Color") as? String
            {
                cell.textLabel?.text = title.capitalized
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 4:
            cell.accessoryType = .disclosureIndicator
            if let title = UserDefaults.standard.object(forKey: "Second Tick Color") as? String
            {
                cell.textLabel?.text = title.capitalized
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 5:
            cell.accessoryType = .disclosureIndicator
            if let title = UserDefaults.standard.object(forKey: "Text Color") as? String
            {
                cell.textLabel?.text = title.capitalized
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 6:
            cell.accessoryType = .disclosureIndicator
            if let title = UserDefaults.standard.object(forKey: "Hour Hand Color") as? String
            {
                cell.textLabel?.text = title.capitalized
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 7:
            cell.accessoryType = .disclosureIndicator
            if let title = UserDefaults.standard.object(forKey: "Minute Hand Color") as? String
            {
                cell.textLabel?.text = title.capitalized
            }
            else
            {
                cell.textLabel?.text = "Black"
            }
            break
        case 8:
            cell.accessoryType = .disclosureIndicator
            if let title = UserDefaults.standard.object(forKey: "Second Hand Color") as? String
            {
                cell.textLabel?.text = title.capitalized
            }
            else
            {
                cell.textLabel?.text = "Red"
            }
            break
        case 9:
            if (UserDefaults.standard.object(forKey: (cell.textLabel?.text)!) != nil) {
                let isOn = UserDefaults.standard.bool(forKey: (cell.textLabel?.text)!)
                if let switchView = cell.accessoryView as? UISwitch
                {
                    switchView.isOn = isOn
                }
                
            }
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell
        {
            let indexPath = self.tableView.indexPath(for: cell)
            if let colorVC = segue.destination as? CustomizeColorTableViewController
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
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        let location = self.tableView.convert(sender.bounds.origin, from: sender)
        let indexPath = self.tableView.indexPathForRow(at: location)
        let cell = self.tableView.cellForRow(at: indexPath!)
        UserDefaults.standard.set(sender.isOn, forKey: (cell!.textLabel?.text)!)
        UserDefaults.standard.synchronize()

    }
    @IBAction func done(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
