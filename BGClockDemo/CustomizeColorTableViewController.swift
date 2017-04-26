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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BGClockView.colorDictionary().keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let color = UserDefaults.standard.object(forKey: userDefaultColorKey!) as? String
        
        let colorStrings:[String] = [String](BGClockView.colorDictionary().keys)
        let title = colorStrings[indexPath.row]
        cell.textLabel?.text = title.capitalized
        
        if title == color || (color == nil && title == "black" && self.navigationItem.title != "Second Hand Color") || (color == nil && title == "red" && self.navigationItem.title == "Second Hand Color")
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let colorStrings:[String] = [String](BGClockView.colorDictionary().keys)
        let color = colorStrings[indexPath.row]
        UserDefaults.standard.set(color, forKey: userDefaultColorKey!)
        UserDefaults.standard.synchronize()
        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Colors"
    }

}
