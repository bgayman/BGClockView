//
//  WorldClockMapAnnotationView.swift
//  BGClockDemo
//
//  Created by Brad G. on 3/12/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit


class WorldClockMapAnnotationView: UIView {
    
    var weatherIcon: UILabel
    var weatherLabel: UILabel!
    var clockView: BGClockView!
    
    var timeZoneLocation:TimeZoneLocation?{
        didSet
        {
            self.clockView.timeZoneNameString = self.timeZoneLocation?.timeZoneName
            self.weatherLabel.text = self.timeZoneLocation?.tempString
            self.weatherIcon.text = self.timeZoneLocation?.weatherIconString
            self.weatherLabel.sizeToFit()
            self.weatherIcon.sizeToFit()
            if self.timeZoneLocation != nil && self.timeZoneLocation!.isDay
            {
                self.clockView.backgroundColor = UIColor.whiteColor()
                self.weatherLabel.textColor = UIColor.blackColor()
                self.weatherIcon.textColor = UIColor.blackColor()
                self.setupClockForDay(self.clockView)
                self.clockView.start()
            }
            else
            {
                self.clockView.backgroundColor = UIColor.blackColor()
                
                self.weatherLabel.textColor = UIColor.whiteColor()
                self.weatherIcon.textColor = UIColor.whiteColor()
                self.setupClockForNight(self.clockView)
                self.clockView.start()
            }
        }
    }

    override init(frame: CGRect) {
        self.clockView = BGClockView(frame: CGRect(x: frame.size.width * 0.5 - 12.5, y: 2.0, width: 25, height: 25))
        self.weatherLabel = UILabel(frame: CGRect(x: 5.0, y: 27, width: frame.size.width * 0.5, height: 25))
        self.weatherLabel.font = UIFont.systemFontOfSize(8.0)
        self.weatherLabel.adjustsFontSizeToFitWidth = true
        self.weatherLabel.minimumScaleFactor = 0.20
        
        self.weatherIcon = UILabel(frame: CGRect(x: frame.size.width * 0.5 + 8.0, y: 27, width: frame.size.width * 0.5, height: 25))
        self.weatherIcon.textAlignment = .Center
        self.weatherIcon.font = UIFont(name: "Weather Icons", size: 8.0)
        self.weatherIcon.adjustsFontSizeToFitWidth = true
        self.weatherIcon.minimumScaleFactor = 0.20
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.addSubview(self.clockView)
        self.addSubview(self.weatherLabel)
        self.addSubview(self.weatherIcon)
        
        
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.clockView.layer.cornerRadius = 25.0 * 0.5
        self.clockView.layer.masksToBounds = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupClockForDay(clockView:BGClockView)
    {
        clockView.backgroundColor = UIColor.whiteColor()
        clockView.minuteTickColor = UIColor.blackColor()
        clockView.secondTickColor = UIColor.blackColor()
        clockView.minuteHandColor = UIColor.blackColor()
        clockView.textColor = UIColor.blackColor()
        clockView.hourHandColor = UIColor.blackColor()
        clockView.secondHandColor = UIColor.redColor()
        clockView.hideDateLabel = true
        clockView.hasDropShadow = true
    }
    
    func setupClockForNight(clockView:BGClockView)
    {
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
    }
}
