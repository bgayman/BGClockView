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
        "red":UIColor.red,
        "blue":UIColor(red:28.0/255.0, green:164.0/255.0, blue:251.0/255.0, alpha:1.0),
        "light blue":UIColor(red:89.0/255.0, green:185.0/255.0, blue:213.0/255.0, alpha:1.0),
        "green":UIColor(red:125.0/255.0, green:226.0/255.0, blue:32.0/255.0, alpha:1.0),
        "turquoise":UIColor(red:143.0/255.0, green:205.0/255.0, blue:193.0/255.0, alpha:1.0),
        "yellow":UIColor(red:254.0/255.0, green:237.0/255.0, blue:39.0/255.0, alpha:1.0),
        "orange":UIColor(red:243.0/255.0, green:138.0/255.0, blue:0.0/255.0, alpha:1.0),
        "black":UIColor.black]
    }
    
    class func colorForString(_ colorString:String) -> UIColor
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
        self.tabBarController?.tabBar.tintColor = UIColor.black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.settingsButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "FontAwesome", size: 22.0)!], for: UIControlState())
        
        self.updateClock()
        
        self.clockView.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ClockCollectionViewCell.updateClock), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.black
        self.tabBarController?.tabBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
    }
    
    func updateClock()
    {
        let faceStyle = UserDefaults.standard.object(forKey: "customizeFaceStyle") as? String
        let handStyle = UserDefaults.standard.object(forKey: "customizeHandStyle") as? String
        let font = UserDefaults.standard.object(forKey: "customizeFont") as? String
        let minuteTickColorString = UserDefaults.standard.object(forKey: "Minute Tick Color") as? String
        let secondTickColorString = UserDefaults.standard.object(forKey: "Second Tick Color") as? String
        let textColorString = UserDefaults.standard.object(forKey: "Text Color") as? String
        let hourHandColorString = UserDefaults.standard.object(forKey: "Hour Hand Color") as? String
        let minuteHandColorString = UserDefaults.standard.object(forKey: "Minute Hand Color") as? String
        let secondHandColorString = UserDefaults.standard.object(forKey: "Second Hand Color") as? String
        
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
        if UserDefaults.standard.object(forKey: "Continuous") != nil
        {
            clockView.continuous = UserDefaults.standard.bool(forKey: "Continuous")
        }
        if UserDefaults.standard.object(forKey: "Hide Date Label") != nil
        {
            clockView.hideDateLabel = UserDefaults.standard.bool(forKey: "Hide Date Label")
        }
        if UserDefaults.standard.object(forKey: "Has Drop Shadow") != nil
        {
            clockView.hasDropShadow = UserDefaults.standard.bool(forKey: "Has Drop Shadow")
        }
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}
