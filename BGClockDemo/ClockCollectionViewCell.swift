//
//  ClockCollectionViewCell.swift
//  BGClockDemo
//
//  Created by Brad G. on 3/11/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

extension BGClockView {
    class func clockFaceStyleForString(clockFaceString:String) -> FaceStyle
    {
        switch clockFaceString {
        case ".Swiss":
            return .Swiss
        case ".Normal":
            return .Normal
        case ".Simple"    :
            return .Simple
        case ".Minimal"    :
            return .Minimal
        case ".Utility"    :
            return .Utility
        case ".BigBen"    :
            return .BigBen
        case ".Melting"    :
            return .Melting
        case ".Plain"    :
            return .Plain
        case ".Square"    :
            return .Square
        case ".Chrono"    :
            return .Chrono
        case ".Flip"    :
            return .Flip
        case ".Zulu"    :
            return .Zulu
        default:
            return .Swiss
        }
    }
    
    class func clockHandStyleForString(clockHandString:String) -> HandStyle
    {
        switch clockHandString{
        case ".Swiss":
            return .Swiss
        case ".AppleWatch":
            return .AppleWatch
        case ".Chrono":
            return .Chrono
        case ".BigBen":
            return .BigBen
        case ".Melting":
            return .Melting
        case ".Minimal":
            return .Minimal
        case ".Plain":
            return .Plain
        default:
            return .Swiss
        }
    }
    
    class func clockFaceStringForFaceStyle(clockFaceStyle:FaceStyle) -> String
    {
        switch clockFaceStyle {
        case .Swiss:
            return ".Swiss"
        case .Normal:
            return ".Normal"
        case .Simple    :
            return ".Simple"
        case .Minimal    :
            return ".Minimal"
        case .Utility    :
            return ".Utility"
        case .BigBen    :
            return ".BigBen"
        case .Melting    :
            return ".Melting"
        case .Plain    :
            return ".Plain"
        case .Square    :
            return ".Square"
        case .Chrono    :
            return ".Chrono"
        case .Flip    :
            return ".Flip"
        case .Zulu    :
            return ".Zulu"
        }
    }
}

class ClockCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nightClockView: BGClockView!
    @IBOutlet weak var dayClockView: BGClockView!
    @IBOutlet weak var timeZoneLabel: UILabel!
    var square = false
    var timeZoneLocation:TimeZoneLocation? {
        didSet{
            self.timeZoneLabel.text = self.timeZoneLocation?.displayName
            if self.timeZoneLocation?.isDay != nil
            {
                self.isDay = (self.timeZoneLocation?.isDay)!
            }
            self.dayClockView.timeZoneNameString = self.timeZoneLocation?.timeZoneName
            self.nightClockView.timeZoneNameString = self.timeZoneLocation?.timeZoneName
        }
    }
    
    var isDay:Bool =  true {
        didSet{
            if self.isDay == true
            {
                self.dayClockView.hidden = false
                self.dayClockView.start()
                
                self.nightClockView.hidden = true
                self.nightClockView.stop()
            }
            else
            {
                self.dayClockView.hidden = true
                self.dayClockView.stop()
                
                self.nightClockView.hidden = false
                self.nightClockView.start()
            }
        }
    }
    
    override func awakeFromNib()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ClockCollectionViewCell.updateClock), name: NSUserDefaultsDidChangeNotification, object: nil)
        self.setupClockForDay(self.dayClockView)
        self.setupClockForNight(self.nightClockView)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if !self.square
        {
            self.dayClockView.layer.cornerRadius = self.dayClockView.bounds.width/2
            self.dayClockView.layer.masksToBounds = true
            self.nightClockView.layer.cornerRadius = self.nightClockView.bounds.width/2
            self.nightClockView.layer.masksToBounds = true
        }
        else
        {
            self.dayClockView.layer.cornerRadius = 3.0
            self.dayClockView.layer.masksToBounds = true
            self.nightClockView.layer.cornerRadius = 3.0
            self.nightClockView.layer.masksToBounds = true
        }
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
    
    func updateClock()
    {
        self.setupClockForDay(self.dayClockView)
        self.setupClockForNight(self.nightClockView)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
