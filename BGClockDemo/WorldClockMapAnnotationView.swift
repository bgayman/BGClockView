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
                self.clockView.backgroundColor = UIColor.white
                self.weatherLabel.textColor = UIColor.black
                self.weatherIcon.textColor = UIColor.black
                self.setupClockForDay(self.clockView)
                self.clockView.start()
            }
            else
            {
                self.clockView.backgroundColor = UIColor.black
                
                self.weatherLabel.textColor = UIColor.white
                self.weatherIcon.textColor = UIColor.white
                self.setupClockForNight(self.clockView)
                self.clockView.start()
            }
        }
    }

    override init(frame: CGRect) {
        self.clockView = BGClockView(frame: CGRect(x: frame.size.width * 0.5 - 12.5, y: 2.0, width: 25, height: 25))
        self.weatherLabel = UILabel(frame: CGRect(x: 5.0, y: 27, width: frame.size.width * 0.5, height: 25))
        self.weatherLabel.font = UIFont.systemFont(ofSize: 8.0)
        self.weatherLabel.adjustsFontSizeToFitWidth = true
        self.weatherLabel.minimumScaleFactor = 0.20
        
        self.weatherIcon = UILabel(frame: CGRect(x: frame.size.width * 0.5 + 8.0, y: 27, width: frame.size.width * 0.5, height: 25))
        self.weatherIcon.textAlignment = .center
        self.weatherIcon.font = UIFont(name: "Weather Icons", size: 8.0)
        self.weatherIcon.adjustsFontSizeToFitWidth = true
        self.weatherIcon.minimumScaleFactor = 0.20
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
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

    func setupClockForDay(_ clockView:BGClockView)
    {
        clockView.backgroundColor = UIColor.white
        clockView.minuteTickColor = UIColor.black
        clockView.secondTickColor = UIColor.black
        clockView.minuteHandColor = UIColor.black
        clockView.textColor = UIColor.black
        clockView.hourHandColor = UIColor.black
        clockView.secondHandColor = UIColor.red
        clockView.hideDateLabel = true
        clockView.hasDropShadow = true
    }
    
    func setupClockForNight(_ clockView:BGClockView)
    {
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
    }
}
