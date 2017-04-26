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

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
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
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.white
            self.sunsetLabel.textColor = UIColor.black
            self.sunsetIcon.textColor = UIColor.black
            self.weatherLabel.textColor = UIColor.black
            self.weatherIconLabel.textColor = UIColor.black
            if self.timeZoneLocation!.sunsetMinute != nil {
                let sunsetMinuteString = self.timeZoneLocation!.sunsetMinute! < 10 ? "0" + String(self.timeZoneLocation!.sunsetMinute!) : String(self.timeZoneLocation!.sunsetMinute!)
                self.sunsetLabel.text = String(self.timeZoneLocation!.sunsetHour!) + ":" + sunsetMinuteString
                self.sunsetIcon.text = ""
            }
            self.navigationController?.navigationBar.tintColor = UIColor.black
            UIApplication.shared.statusBarStyle = .default
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        }
        else
        {
            self.tabBarController?.tabBar.barTintColor = UIColor.black
            self.tabBarController?.tabBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            self.sunsetLabel.textColor = UIColor.white
            self.sunsetIcon.textColor = UIColor.white
            self.weatherLabel.textColor = UIColor.white
            self.weatherIconLabel.textColor = UIColor.white
            if self.timeZoneLocation!.sunsetMinute != nil {
                let sunriseMinuteString = self.timeZoneLocation!.sunriseMinute! < 10 ? "0" + String(self.timeZoneLocation!.sunriseMinute!) : String(self.timeZoneLocation!.sunriseMinute!)
                self.sunsetLabel.text = String(self.timeZoneLocation!.sunriseHour!) + ":" + sunriseMinuteString
                self.sunsetIcon.text = ""
            }
            self.navigationController?.navigationBar.tintColor = UIColor.white
            UIApplication.shared.statusBarStyle = .lightContent
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func setupClockForDay(_ clockView:BGClockView)
    {
        let faceStyle = UserDefaults.standard.object(forKey: "faceStyle") as? String
        let handStyle = UserDefaults.standard.object(forKey: "handStyle") as? String
        
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
        
        clockView.backgroundColor = UIColor.white
        clockView.minuteTickColor = UIColor.black
        clockView.secondTickColor = UIColor.black
        clockView.minuteHandColor = UIColor.black
        clockView.textColor = UIColor.black
        clockView.hourHandColor = UIColor.black
        clockView.secondHandColor = UIColor.red
        clockView.hideDateLabel = true
        clockView.hasDropShadow = true
        if clockView.face == .flip
        {
            clockView.textColor = UIColor.white
        }
    }
    
    func setupClockForNight(_ clockView:BGClockView)
    {
        let faceStyle = UserDefaults.standard.object(forKey: "faceStyle") as? String
        let handStyle = UserDefaults.standard.object(forKey: "handStyle") as? String
        
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
        
        clockView.backgroundColor = UIColor.black
        clockView.minuteTickColor = UIColor.white
        clockView.secondTickColor = UIColor.white
        clockView.minuteHandColor = UIColor.white
        clockView.screwColor = UIColor.black
        clockView.textColor = UIColor.white
        clockView.hourHandColor = UIColor.white
        clockView.secondHandColor = UIColor(red: 134.0/255.0, green: 96.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        clockView.hideDateLabel = true
        clockView.hasDropShadow = true
        if clockView.face == .flip
        {
            clockView.textColor = UIColor.black
        }
    }

}
