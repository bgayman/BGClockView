//
//  ClockViewController.swift
//  Apple Watch
//
//  Created by Brad G. on 3/5/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {
    
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunsetIcon: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherIconLabel: UILabel!
    @IBOutlet weak var clockView: BGClockView!
    var timeZoneLocation:TimeZoneLocation?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if self.timeZoneLocation != nil && self.timeZoneLocation!.isDay
        {
            self.setupClockForDay(self.clockView)
        }
        else
        {
            self.setupClockForNight(self.clockView)
        }
        self.clockView.start()
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        self.title = self.timeZoneLocation?.displayName
        self.clockView.timeZoneNameString = self.timeZoneLocation?.timeZoneName
        if let tempString = self.timeZoneLocation?.tempString
        {
            self.weatherLabel.text = tempString
        }
        if let weatherIconString = self.timeZoneLocation?.weatherIconString
        {
            self.weatherIconLabel.text = weatherIconString
        }

        if self.timeZoneLocation != nil && self.timeZoneLocation!.isDay
        {
            self.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
            self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
            self.view.backgroundColor = UIColor.whiteColor()
            self.sunsetLabel.textColor = UIColor.blackColor()
            self.sunsetIcon.textColor = UIColor.blackColor()
            self.weatherLabel.textColor = UIColor.blackColor()
            self.weatherIconLabel.textColor = UIColor.blackColor()
            if self.timeZoneLocation!.sunsetMinute != nil {
                let sunsetMinuteString = self.timeZoneLocation!.sunsetMinute! < 10 ? "0" + String(self.timeZoneLocation!.sunsetMinute!) : String(self.timeZoneLocation!.sunsetMinute!)
                self.sunsetLabel.text = String(self.timeZoneLocation!.sunsetHour!) + ":" + sunsetMinuteString
                self.sunsetIcon.text = ""
            }
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            UIApplication.sharedApplication().statusBarStyle = .Default
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        }
        else
        {
            self.tabBarController?.tabBar.barTintColor = UIColor.blackColor()
            self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
            self.view.backgroundColor = UIColor.blackColor()
            self.sunsetLabel.textColor = UIColor.whiteColor()
            self.sunsetIcon.textColor = UIColor.whiteColor()
            self.weatherLabel.textColor = UIColor.whiteColor()
            self.weatherIconLabel.textColor = UIColor.whiteColor()
            if self.timeZoneLocation!.sunsetMinute != nil {
                let sunriseMinuteString = self.timeZoneLocation!.sunriseMinute! < 10 ? "0" + String(self.timeZoneLocation!.sunriseMinute!) : String(self.timeZoneLocation!.sunriseMinute!)
                self.sunsetLabel.text = String(self.timeZoneLocation!.sunriseHour!) + ":" + sunriseMinuteString
                self.sunsetIcon.text = ""
            }
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func setupClockForDay(clockView:BGClockView)
    {
        let faceStyle = NSUserDefaults.standardUserDefaults().objectForKey("faceStyle") as? String
        let handStyle = NSUserDefaults.standardUserDefaults().objectForKey("handStyle") as? String
        
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
        
        clockView.backgroundColor = UIColor.whiteColor()
        clockView.minuteTickColor = UIColor.blackColor()
        clockView.secondTickColor = UIColor.blackColor()
        clockView.minuteHandColor = UIColor.blackColor()
        clockView.textColor = UIColor.blackColor()
        clockView.hourHandColor = UIColor.blackColor()
        clockView.secondHandColor = UIColor.redColor()
        clockView.hideDateLabel = true
        clockView.hasDropShadow = true
        if clockView.face == .Flip
        {
            clockView.textColor = UIColor.whiteColor()
        }
    }
    
    func setupClockForNight(clockView:BGClockView)
    {
        let faceStyle = NSUserDefaults.standardUserDefaults().objectForKey("faceStyle") as? String
        let handStyle = NSUserDefaults.standardUserDefaults().objectForKey("handStyle") as? String
        
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
        
        clockView.backgroundColor = UIColor.blackColor()
        clockView.minuteTickColor = UIColor.whiteColor()
        clockView.secondTickColor = UIColor.whiteColor()
        clockView.minuteHandColor = UIColor.whiteColor()
        clockView.screwColor = UIColor.blackColor()
        clockView.textColor = UIColor.whiteColor()
        clockView.hourHandColor = UIColor.whiteColor()
        clockView.secondHandColor = UIColor(red: 134.0/255.0, green: 96.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        clockView.hideDateLabel = true
        clockView.hasDropShadow = true
        if clockView.face == .Flip
        {
            clockView.textColor = UIColor.blackColor()
        }
    }

}
