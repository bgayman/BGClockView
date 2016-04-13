//
//  BGClockCustomizationViewController.swift
//  BGClockDemo
//
//  Created by Brad G. on 4/9/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

extension BGClockView{
    class func colorDictionary() -> [String:UIColor]
    {
        return ["antique white": UIColor(red:201.0/255.0, green:168.0/255.0, blue:130.0/255.0, alpha:1.0),
        "walnut":UIColor(red:159.0/255.0, green:115.0/255.0, blue:80.0/255.0, alpha:1.0),
        "stone":UIColor(red:158.0/255.0, green:136.0/255.0, blue:108.0/255.0, alpha:1.0),
        "vintage rose":UIColor(red:239.0/255.0, green:154.0/255.0, blue:148.0/255.0, alpha:1.0),
        "pink":UIColor(red:251.0/255.0, green:64.0/255.0, blue:80.0/255.0, alpha:1.0),
        "lavender":UIColor(red:161.0/255.0, green:135.0/255.0, blue:149.0/255.0, alpha:1.0),
        "purple":UIColor(red:134.0/255.0, green:96.0/255.0, blue:245.0/255.0, alpha:1.0),
        "midnight blue":UIColor(red:78.0/255.0, green:111.0/255.0, blue:177.0/255.0, alpha:1.0),
        "red":UIColor.redColor(),
        "blue":UIColor(red:28.0/255.0, green:164.0/255.0, blue:251.0/255.0, alpha:1.0),
        "light blue":UIColor(red:89.0/255.0, green:185.0/255.0, blue:213.0/255.0, alpha:1.0),
        "green":UIColor(red:125.0/255.0, green:226.0/255.0, blue:32.0/255.0, alpha:1.0),
        "turquoise":UIColor(red:143.0/255.0, green:205.0/255.0, blue:193.0/255.0, alpha:1.0),
        "yellow":UIColor(red:254.0/255.0, green:237.0/255.0, blue:39.0/255.0, alpha:1.0),
        "orange":UIColor(red:243.0/255.0, green:138.0/255.0, blue:0.0/255.0, alpha:1.0),
        "black":UIColor.blackColor()]
    }
    
    class func colorForString(colorString:String) -> UIColor
    {
        return BGClockView.colorDictionary()[colorString]!
    }

}

class BGClockCustomizationViewController: UIViewController {

    @IBOutlet weak var clockView: BGClockView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.settingsButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "FontAwesome", size: 22.0)!], forState: .Normal)
        
        self.updateClock()
        
        self.clockView.start()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ClockCollectionViewCell.updateClock), name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
        self.tabBarController?.tabBar.translucent = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
    }
    
    func updateClock()
    {
        let faceStyle = NSUserDefaults.standardUserDefaults().objectForKey("customizeFaceStyle") as? String
        let handStyle = NSUserDefaults.standardUserDefaults().objectForKey("customizeHandStyle") as? String
        let font = NSUserDefaults.standardUserDefaults().objectForKey("customizeFont") as? String
        let minuteTickColorString = NSUserDefaults.standardUserDefaults().objectForKey("Minute Tick Color") as? String
        let secondTickColorString = NSUserDefaults.standardUserDefaults().objectForKey("Second Tick Color") as? String
        let textColorString = NSUserDefaults.standardUserDefaults().objectForKey("Text Color") as? String
        let hourHandColorString = NSUserDefaults.standardUserDefaults().objectForKey("Hour Hand Color") as? String
        let minuteHandColorString = NSUserDefaults.standardUserDefaults().objectForKey("Minute Hand Color") as? String
        let secondHandColorString = NSUserDefaults.standardUserDefaults().objectForKey("Second Hand Color") as? String
        
        if font != nil
        {
            clockView.faceFont = UIFont(name: font!, size: 14.0)!
        }
        if minuteTickColorString != nil
        {
            clockView.minuteTickColor = BGClockView.colorForString(minuteTickColorString!)
        }
        if secondTickColorString != nil
        {
            clockView.secondTickColor = BGClockView.colorForString(secondTickColorString!)
        }
        if textColorString != nil
        {
            clockView.textColor = BGClockView.colorForString(textColorString!)
        }
        if hourHandColorString != nil
        {
            clockView.hourHandColor = BGClockView.colorForString(hourHandColorString!)
        }
        if minuteHandColorString != nil
        {
            clockView.minuteHandColor = BGClockView.colorForString(minuteHandColorString!)
        }
        if secondHandColorString != nil
        {
            clockView.secondHandColor = BGClockView.colorForString(secondHandColorString!)
        }
        if faceStyle != nil && faceStyle != "Image"
        {
            clockView.face = BGClockView.clockFaceStyleForString(faceStyle!)
        }
        else if faceStyle == "Image"
        {
            clockView.clockFaceImage = UIImage(named: "clockFace")
        }
        if handStyle != nil && handStyle != "Image"
        {
            clockView.hand = BGClockView.clockHandStyleForString(handStyle!)
        }
        else if handStyle == "Image"
        {
            clockView.hourHandImage = UIImage(named: "hourHand")
            clockView.minuteHandImage = UIImage(named: "minuteHand")
            clockView.secondHandImage = UIImage(named: "secondHand")
        }
        if NSUserDefaults.standardUserDefaults().objectForKey("Continuous") != nil
        {
            clockView.continuous = NSUserDefaults.standardUserDefaults().boolForKey("Continuous")
        }
        if NSUserDefaults.standardUserDefaults().objectForKey("Hide Date Label") != nil
        {
            clockView.hideDateLabel = NSUserDefaults.standardUserDefaults().boolForKey("Hide Date Label")
        }
        if NSUserDefaults.standardUserDefaults().objectForKey("Has Drop Shadow") != nil
        {
            clockView.hasDropShadow = NSUserDefaults.standardUserDefaults().boolForKey("Has Drop Shadow")
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
