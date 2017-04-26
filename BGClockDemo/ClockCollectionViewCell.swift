//
//  ClockCollectionViewCell.swift
//  BGClockDemo
//
//  Created by Brad G. on 3/11/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

extension BGClockView {
    class func clockFaceStyleForString(_ clockFaceString:String) -> FaceStyle
    {
        switch clockFaceString {
        case ".Swiss":
            return .swiss
        case ".Normal":
            return .normal
        case ".Simple"    :
            return .simple
        case ".Minimal"    :
            return .minimal
        case ".Utility"    :
            return .utility
        case ".BigBen"    :
            return .bigBen
        case ".Melting"    :
            return .melting
        case ".Plain"    :
            return .plain
        case ".Square"    :
            return .square
        case ".Chrono"    :
            return .chrono
        case ".Flip"    :
            return .flip
        case ".Zulu"    :
            return .zulu
        default:
            return .swiss
        }
    }
    
    class func clockHandStyleForString(_ clockHandString:String) -> HandStyle
    {
        switch clockHandString{
        case ".Swiss":
            return .swiss
        case ".AppleWatch":
            return .appleWatch
        case ".Chrono":
            return .chrono
        case ".BigBen":
            return .bigBen
        case ".Melting":
            return .melting
        case ".Minimal":
            return .minimal
        case ".Plain":
            return .plain
        default:
            return .swiss
        }
    }
    
    class func clockFaceStringForFaceStyle(_ clockFaceStyle:FaceStyle) -> String
    {
        switch clockFaceStyle {
        case .swiss:
            return ".Swiss"
        case .normal:
            return ".Normal"
        case .simple    :
            return ".Simple"
        case .minimal    :
            return ".Minimal"
        case .utility    :
            return ".Utility"
        case .bigBen    :
            return ".BigBen"
        case .melting    :
            return ".Melting"
        case .plain    :
            return ".Plain"
        case .square    :
            return ".Square"
        case .chrono    :
            return ".Chrono"
        case .flip    :
            return ".Flip"
        case .zulu    :
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
                self.dayClockView.isHidden = false
                self.dayClockView.start()
                
                self.nightClockView.isHidden = true
                self.nightClockView.stop()
            }
            else
            {
                self.dayClockView.isHidden = true
                self.dayClockView.stop()
                
                self.nightClockView.isHidden = false
                self.nightClockView.start()
            }
        }
    }
    
    override func awakeFromNib()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ClockCollectionViewCell.updateClock), name: UserDefaults.didChangeNotification, object: nil)
        self.setupClockForDay(self.dayClockView)
        self.setupClockForNight(self.nightClockView)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    
        self.dayClockView.layer.cornerRadius = 3.0
        self.dayClockView.layer.masksToBounds = true
        self.nightClockView.layer.cornerRadius = 3.0
        self.nightClockView.layer.masksToBounds = true
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
    
    func updateClock()
    {
        self.setupClockForDay(self.dayClockView)
        self.setupClockForNight(self.nightClockView)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}
