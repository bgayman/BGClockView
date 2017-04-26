//
//  BGClockView.swift
//  Clock
//
//  Created by Brad G. on 2/25/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum FaceStyle
{
    case swiss
    case normal
    case simple
    case utility
    case bigBen
    case melting
    case minimal
    case plain
    case square
    case chrono
    case flip
    case zulu
}

enum HandStyle
{
    case swiss
    case appleWatch
    case chrono
    case bigBen
    case melting
    case minimal
    case plain
}

//MARK: - Clock View

class BGClockView: UIView {
    fileprivate var clockFace:BGClockFaceView =      BGClockFaceView()
    fileprivate var hourHand:BGClockHandView =       BGClockHourHandView()
    fileprivate var minHand:BGClockHandView =        BGClockMinuteHandView()
    fileprivate var secHand:BGClockHandView =        BGClockSecondHandView()
    fileprivate var chronosSecondHandTop:            UIView?
    fileprivate var chronosSecondHandBottom:         UIView?
    fileprivate var dateLabel:                       UILabel?
    
    /**
     * The time zone name for the time displayed on the clock, for example `America/New_York`. A complete list is available by calling `NSTimeZone.knownTimeZoneNames()`
     */
    var timeZoneNameString:                      String?
    fileprivate var displayLink:                     CADisplayLink?
    
    /**
     * Bool that determines if the second hand should sweep continously or tick by the second.
     */
    var continuous =                             true
    
    /**
     * Bool that determines if clock hands have drop shadows.
     */
    var hasDropShadow =                          false{
        didSet{
            self.secHand.hasDropShadow = self.hasDropShadow
            self.minHand.hasDropShadow = self.hasDropShadow
            self.hourHand.hasDropShadow = self.hasDropShadow
            
            self.secHand.setNeedsDisplay()
            self.minHand.setNeedsDisplay()
            self.hourHand.setNeedsDisplay()
        }
    }
    
    /**
     * Bool that determines if clock face shows a date string. This applies to most but not all clock face
     */
    var hideDateLabel = false{
        didSet{
            self.dateLabel?.isHidden = self.hideDateLabel
        }
    }
    
    /**
     * UIColor that sets the color for larger five-minute tick marks on clock face
     */
    var minuteTickColor:UIColor{
        didSet{
            self.clockFace.minuteTickColor = self.minuteTickColor
            self.clockFace.setNeedsDisplay()
        }
    }
    
    /**
     * UIColor that sets the color for smaller tick marks on clock face
     */
    var secondTickColor:UIColor{
        didSet{
            self.clockFace.secondTickColor = self.secondTickColor
            self.clockFace.setNeedsDisplay()
        }
    }
    
    /**
     * UIColor that sets the color for numerals and text on clock face
     */
    var textColor:UIColor{
        didSet{
            self.clockFace.textColor = self.textColor
            self.clockFace.setNeedsDisplay()
        }
    }
    
    /**
     * UIColor that sets the color for the hour hand
     */
    var hourHandColor:UIColor{
        didSet{
            self.hourHand.handColor = self.hourHandColor
            self.hourHand.setNeedsDisplay()
        }
    }
    
    /**
     * UIColor that sets the color for minute hand
     */
    var minuteHandColor:UIColor{
        didSet{
            self.minHand.handColor = self.minuteHandColor
            self.minHand.setNeedsDisplay()
        }
    }
    
    /**
     * UIColor that sets the color for second hand
     */
    var secondHandColor:UIColor{
        didSet{
            self.secHand.handColor = self.secondHandColor
            self.secHand.setNeedsDisplay()
        }
    }
    
    /**
     * UIColor that sets the center "screw"
     */
    var screwColor:UIColor{
        didSet{
            self.secHand.secondHandScrewColor = self.screwColor
            self.secHand.setNeedsDisplay()
        }
    }
    
    /**
     * UIFont used for numerals and text on clock face. The font size will be set by the clock view so can be arbitary.
     */
    var faceFont:UIFont{
        didSet{
            self.clockFace.faceFont = self.faceFont
            self.clockFace.setNeedsDisplay()
        }
    }
    
    /**
     * FaceStyle used to draw the clock's face. This property is ignored if clockFaceImage is set
     */
    var face: FaceStyle {
        didSet {
            for view in self.subviews{
                view.removeFromSuperview()
            }
            self.defaultSetup()
        }
    }
    
    /**
     * HandStyle used to draw the clock's hands. This property is ignored if andy of the clock hand images are set
     */
    var hand: HandStyle{
        didSet{
            self.secHand.removeFromSuperview()
            self.minHand.removeFromSuperview()
            self.hourHand.removeFromSuperview()
            self.defaultSetup()
        }
    }
    
    fileprivate var secondHandImageView:UIImageView?
    
    /**
     * UIImage used to as the clock's second hand. Image should have hand pointing to 12 o'clock.
     */
    var secondHandImage:UIImage?{
        didSet{
            if self.secondHandImageView?.superview != nil
            {
                self.secondHandImageView?.image = secondHandImage
            }else{
                let secondHandIV = UIImageView(frame: self.clockFace.frame)
                secondHandIV.image = self.secondHandImage
                self.secondHandImageView = secondHandIV
                self.secondHandImageView?.contentMode = .scaleAspectFit
                self.insertSubview(self.secondHandImageView!, belowSubview: self.secHand)
                self.secHand.removeFromSuperview()
            }
        }
    }
    
    fileprivate var minuteHandImageView:UIImageView?
    
    /**
     * UIImage used to as the clock's minute hand. Image should have hand pointing to 12 o'clock.
     */
    var minuteHandImage:UIImage?{
        didSet{
            if self.minuteHandImageView?.superview != nil
            {
                self.minuteHandImageView?.image = minuteHandImage
            }else{
                let minuteHandIV = UIImageView(frame: self.clockFace.frame)
                minuteHandIV.image = self.minuteHandImage
                self.minuteHandImageView = minuteHandIV
                self.minuteHandImageView?.contentMode = .scaleAspectFit
                self.insertSubview(self.minuteHandImageView!, belowSubview: self.minHand)
                self.minHand.removeFromSuperview()
            }
        }
    }
    
    fileprivate var hourHandImageView:UIImageView?
    
    /**
     * UIImage used to as the clock's hour hand. Image should have hand pointing to 12 o'clock.
     */
    var hourHandImage:UIImage?{
        didSet{
            if self.hourHandImageView?.superview != nil
            {
                self.hourHandImageView?.image = hourHandImage
            }else{
                let hourHandIV = UIImageView(frame: self.clockFace.frame)
                hourHandIV.image = self.hourHandImage
                self.hourHandImageView = hourHandIV
                self.hourHandImageView?.contentMode = .scaleAspectFit
                self.insertSubview(self.hourHandImageView!, belowSubview: self.hourHand)
                self.hourHand.removeFromSuperview()
            }
        }
    }
    
    fileprivate var clockFaceImageView:UIImageView?
    
    /**
     * UIImage used to as the clock's face.
     */
    var clockFaceImage:UIImage?{
        didSet{
            if self.clockFaceImageView?.superview != nil
            {
                self.clockFaceImageView?.image = clockFaceImage
            }else{
                let clockFaceIV = UIImageView(frame: self.clockFace.frame)
                clockFaceIV.image = self.clockFaceImage
                self.clockFaceImageView = clockFaceIV
                self.clockFaceImageView?.contentMode = .scaleAspectFit
                self.insertSubview(self.clockFaceImageView!, belowSubview: self.clockFace)
                self.clockFace.removeFromSuperview()
            }
        }
    }
    
    override init(frame: CGRect)
    {
        
        self.minuteTickColor = UIColor.black
        self.secondTickColor = UIColor.black
        self.textColor =       UIColor.black
        self.minuteHandColor = UIColor.black
        self.hourHandColor =   UIColor.black
        self.secondHandColor = UIColor.red
        self.screwColor =      UIColor.white
        self.faceFont =        UIFont.systemFont(ofSize: 12.0)
        
        self.face = .swiss
        self.hand = .swiss
        
        super.init(frame: frame)
        defaultSetup()
        self.contentMode = .redraw
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        
        self.minuteTickColor = UIColor.black
        self.secondTickColor = UIColor.black
        self.textColor = UIColor.black
        self.minuteHandColor = UIColor.black
        self.hourHandColor = UIColor.black
        self.secondHandColor = UIColor.red
        self.screwColor =      UIColor.white
        self.faceFont =        UIFont.systemFont(ofSize: 12.0)
        
        self.face = .swiss
        self.hand = .swiss
        
        super.init(coder: aDecoder)
        defaultSetup()
        self.contentMode = .redraw
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override var bounds: CGRect {
        didSet {
            for view in self.subviews{
                view.removeFromSuperview()
            }
            self.defaultSetup()
        }
    }
    
    fileprivate func updateUI()
    {
        self.clockFace.faceFont =           self.faceFont
        self.clockFace.minuteTickColor =    self.minuteTickColor
        self.clockFace.secondTickColor =    self.secondTickColor
        self.clockFace.textColor =          self.textColor
        self.secHand.handColor =            self.secondHandColor
        self.minHand.handColor =            self.minuteHandColor
        self.hourHand.handColor =           self.hourHandColor
        self.secHand.secondHandScrewColor = self.screwColor
        self.secHand.hasDropShadow =        self.hasDropShadow
        self.minHand.hasDropShadow =        self.hasDropShadow
        self.hourHand.hasDropShadow =       self.hasDropShadow
    }
    
    fileprivate func defaultSetup()
    {
        
        self.setupFace()
        self.setupHands()
        
        self.updateUI()
        
        if self.face != .square {
            if self.bounds.size.width < self.bounds.size.height
            {
                self.clockFace.frame = CGRect(x: 0.0, y: (self.bounds.size.height-self.bounds.size.width)*0.5, width: self.bounds.size.width, height: self.bounds.size.width)
            }else{
                self.clockFace.frame = CGRect(x: (self.bounds.size.width-self.bounds.size.height)*0.5,y: 0.0 , width: self.bounds.size.height, height: self.bounds.size.height)
            }
            self.hourHand.frame = self.clockFace.frame
            self.minHand.frame = self.clockFace.frame
            self.secHand.frame = self.clockFace.frame
        }
        else
        {
            self.clockFace.frame = self.bounds
            var handRect:CGRect
            if self.bounds.size.width < self.bounds.size.height
            {
                handRect = CGRect(x: 0.0, y: (self.bounds.size.height-self.bounds.size.width)*0.5, width: self.bounds.size.width, height: self.bounds.size.width)
            }else{
                handRect = CGRect(x: (self.bounds.size.width-self.bounds.size.height)*0.5,y: 0.0 , width: self.bounds.size.height, height: self.bounds.size.height)
            }
            self.hourHand.frame = handRect
            self.minHand.frame = handRect
            self.secHand.frame = handRect
        }
        
        
        
        if self.face == .melting
        {
            self.hourHand.frame.size = CGSize(width:self.clockFace.bounds.size.width * 0.5,height:self.clockFace.bounds.size.height * 0.5)
            self.minHand.frame.size = CGSize(width:self.clockFace.bounds.size.width * 0.5,height:self.clockFace.bounds.size.height * 0.5)
            self.secHand.frame.size = CGSize(width:self.clockFace.bounds.size.width * 0.5,height:self.clockFace.bounds.size.height * 0.5)
            
            self.hourHand.center = CGPoint(x: self.clockFace.center.x + self.clockFace.bounds.size.width * 0.08, y: self.clockFace.center.y - self.clockFace.bounds.size.height * 0.10)
            self.minHand.center = CGPoint(x: self.clockFace.center.x + self.clockFace.bounds.size.width * 0.08, y: self.clockFace.center.y - self.clockFace.bounds.size.height * 0.10)
            self.secHand.center = CGPoint(x: self.clockFace.center.x + self.clockFace.bounds.size.width * 0.08, y: self.clockFace.center.y - self.clockFace.bounds.size.height * 0.10)
        }
        
        self.addSubview(self.clockFace)
        
        if self.face != .flip
        {
            self.addSubview(self.hourHand)
            self.addSubview(self.minHand)
        }
        
        if self.hand != .bigBen && self.face != .flip
        {
            self.addSubview(self.secHand)
        }
        
        if self.face != .bigBen && self.face != .melting && self.face != .flip
        {
            if self.face != .simple && self.face != .swiss && self.face != .chrono
            {
                self.dateLabel = UILabel(frame: CGRect(x: self.clockFace.bounds.size.width*0.725-self.clockFace.bounds.size.width*0.07, y: self.clockFace.bounds.size.height*0.5-self.clockFace.bounds.size.height*0.07, width: self.clockFace.bounds.size.width*0.14, height: self.clockFace.bounds.size.height*0.14))
            }
            else if self.face == .chrono
            {
                self.dateLabel = UILabel(frame: CGRect(x: self.clockFace.bounds.size.width*0.70-self.clockFace.bounds.size.width*0.11, y: self.clockFace.bounds.size.height*0.5-self.clockFace.bounds.size.height*0.08, width: self.clockFace.bounds.size.width*0.24, height: self.clockFace.bounds.size.height*0.14))
            }
            else
            {
                self.dateLabel = UILabel(frame: CGRect(x: self.clockFace.bounds.size.width*0.70-self.clockFace.bounds.size.width*0.07, y: self.clockFace.bounds.size.height*0.5-self.clockFace.bounds.size.height*0.07, width: self.clockFace.bounds.size.width*0.14, height: self.clockFace.bounds.size.height*0.14))
            }
            
            self.dateLabel?.isHidden = self.hideDateLabel
            self.dateLabel?.textAlignment = .center
            self.dateLabel?.textColor = self.textColor
            self.dateLabel?.font = self.faceFont.withSize(self.clockFace.bounds.size.height*0.08)
            self.dateLabel?.minimumScaleFactor = 0.5
            self.dateLabel?.adjustsFontSizeToFitWidth = true
            self.clockFace.addSubview(self.dateLabel!)
        }
    }
    
    fileprivate func setupFace()
    {
        switch self.face {
        case .swiss:
            self.clockFace = BGClockFaceView()
            break
        case .normal:
            self.clockFace = BGNormalClockFaceView()
            break
        case .simple    :
            self.clockFace = BGSimpleClockFaceView()
            break
        case .minimal    :
            self.clockFace = BGMinimalClockFaceView()
            break
        case .utility    :
            self.clockFace = BGUtilityClockFaceView()
            break
        case .bigBen    :
            self.clockFace = BGBigBenClockFaceView()
            break
        case .melting    :
            self.clockFace = BGMeltingClockFaceView()
            break
        case .plain    :
            self.clockFace = BGPlainClockFaceView()
            break
        case .square    :
            self.clockFace = BGSquareClockFaceView()
            break
        case .chrono    :
            self.clockFace = BGChronoClockFaceView()
            break
        case .flip    :
            self.clockFace = BGFlipClockFaceView()
            break
        case .zulu    :
            self.clockFace = BG24HourClockFaceView()
            break
        }
    }
    
    fileprivate func setupHands()
    {
        switch self.hand {
        case .swiss:
            self.hourHand = BGClockHourHandView()
            self.minHand = BGClockMinuteHandView()
            self.secHand = BGClockSecondHandView()
            break
        case .appleWatch:
            self.hourHand = BGAppleWatchClockHourHandView()
            self.minHand = BGAppleWatchClockMinuteHandView()
            self.secHand = BGAppleWatchClockSecondHandView()
            break
        case .bigBen:
            self.hourHand = BGBigBenClockHourHandView()
            self.minHand = BGBigBenClockMinuteHandView()
            break
        case .melting:
            self.hourHand = BGMeltingClockHourHandView()
            self.minHand = BGMeltingClockMinuteHandView()
            self.secHand = BGMeltingClockSecondHandView()
            break
        case .minimal:
            self.hourHand = BGMinimalClockHourHandView()
            self.minHand = BGMinimalClockMinuteHandView()
            self.secHand = BGMinimalClockSecondHandView()
            break
        case .chrono:
            self.hourHand = BGAppleWatchChronoClockHourHandView()
            self.minHand = BGAppleWatchChronoClockMinuteHandView()
            self.secHand = BGAppleWatchClockSecondHandView()
            break
        case .plain:
            self.hourHand = BGPlainClockHourHandView()
            self.minHand = BGPlainClockMinuteHandView()
            self.secHand = BGAppleWatchClockSecondHandView()
            break
        }
        
    }
    
    /**
     * Begin animating the clock
     */
    func start()
    {
        self.displayLink = CADisplayLink(target: self, selector: #selector(BGClockView.updateClock))
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    /**
     * Stop animating the clock
     */
    func stop()
    {
        self.displayLink?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    /**
     * Set the clock to a specified time
     * Parameter: day is the day of the month
     * Parameter: hours is the hour of the day with 0 being midnight and 23 being 11 pm
     * Parameter: minute is the minute of the hour
     * Parameter: second is the seconds of the minute
     * Parameter: weekday is the day of the week 1 being Sunday and 7 being Saturday (only used with .Chrono face)
     */
    func setClockToTime(_ day:Int,hours:Int,minute:Int,second:Int,weekday:Int)
    {
        
        let secondsFloat     = CGFloat(second)
        let minutesFloat     = CGFloat(minute) + secondsFloat/60.0
        
        var secAngle = degreesToRadians(CGFloat(second)/60.0 * 360.0)
        var minAngle  = degreesToRadians(minutesFloat/60.0 * 360.0)
        var hour  = hours
        
        if hour > 12
        {
            hour -= 12
        }
        
        let hoursFloat = CGFloat(hour) + minutesFloat/60.0
        
        var hourAngle = degreesToRadians(hoursFloat/12.0 * 360.0)
        
        if self.face == .melting && self.face != .flip
        {
            let secScaleTransform = CGAffineTransform(scaleX: 1.0, y: abs(cos(secAngle)) * 0.25 + 0.75)
            let minScaleTransform = CGAffineTransform(scaleX: 1.0, y: abs(cos(minAngle)) * 0.25 + 0.75)
            let hourScaleTransform = CGAffineTransform(scaleX: 1.0, y: abs(cos(hourAngle)) * 0.25 + 0.75)
            
            secAngle  += degreesToRadians(-55.0)
            minAngle  += degreesToRadians(-55.0)
            hourAngle += degreesToRadians(-55.0)
            
            self.secHand.transform = secScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: secAngle))
            self.minHand.transform = minScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: minAngle))
            self.hourHand.transform = hourScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: hourAngle))
            self.secondHandImageView?.transform = secScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: secAngle))
            self.minuteHandImageView?.transform = minScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: minAngle))
            self.hourHandImageView?.transform = hourScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: hourAngle))
        }
        else if self.face != .flip
        {
            self.secHand.transform = CGAffineTransform.identity.rotated(by: secAngle)
            self.minHand.transform = CGAffineTransform.identity.rotated(by: minAngle)
            self.hourHand.transform = CGAffineTransform.identity.rotated(by: hourAngle)
            self.secondHandImageView?.transform = CGAffineTransform.identity.rotated(by: secAngle)
            self.minuteHandImageView?.transform = CGAffineTransform.identity.rotated(by: minAngle)
            self.hourHandImageView?.transform = CGAffineTransform.identity.rotated(by: hourAngle)
        }
        else
        {
            let flipClockFace = self.clockFace as! BGFlipClockFaceView
            if (flipClockFace.hour != hour || flipClockFace.hour == nil) && !flipClockFace.hourAnimating
            {
                flipClockFace.hourAnimating = true
                flipClockFace.animateHourFlipWithHour(hour)
            }
            if (flipClockFace.minutes != minute || flipClockFace.minutes == nil) && !flipClockFace.minuteAnimating
            {
                flipClockFace.minuteAnimating = true
                flipClockFace.animateMinuteFlipWithMinute(minute)
            }
        }
        
        self.dateLabel?.text = String(stringInterpolationSegment: day)
        
        if self.face == .chrono
        {
            self.dateLabel?.text = weekdayStringForWeekday(weekday) + " \(day)"
        }
        else
        {
            self.dateLabel?.text = String(stringInterpolationSegment: day)
        }
    }
    
    func updateClock()
    {
        var dateComponents:DateComponents
        if self.timeZoneNameString == nil
        {
            dateComponents = (Calendar.current as NSCalendar).components([.day,.hour,.minute,.second,.nanosecond,.weekday], from: Date())
        }
        else
        {
            var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            calendar.timeZone = TimeZone(identifier: self.timeZoneNameString!)!
            dateComponents = (calendar as NSCalendar).components([.day,.hour,.minute,.second,.nanosecond,.weekday], from: Date())
        }
        let seconds     = dateComponents.second
        let minutes     = dateComponents.minute
        let hours       = dateComponents.hour
        let day         = dateComponents.day
        let nanoSeconds = dateComponents.nanosecond
        let weekday     = dateComponents.weekday
        
        let nanoSecondsFloat = CGFloat(nanoSeconds!)/1000000000.0
        let secondsFloat     = CGFloat(seconds!) + nanoSecondsFloat
        let minutesFloat     = CGFloat(minutes!) + secondsFloat/60.0
        let twelveHoursHour:Int
        if hours > 12
        {
            twelveHoursHour = hours! - 12
        }
        else
        {
            twelveHoursHour = hours!
        }
        
        let hoursFloat = CGFloat(twelveHoursHour) + minutesFloat/60.0
        let twentyFourHoursFloat = CGFloat(hours!) + minutesFloat/60.0
        
        var secAngle: CGFloat
        
        if self.continuous
        {
            secAngle  = degreesToRadians(secondsFloat/60.0 * 360.0)
        }
        else
        {
            secAngle = degreesToRadians(CGFloat(seconds!)/60.0 * 360.0)
        }
        
        var minAngle  = degreesToRadians(minutesFloat/60.0 * 360.0)
        var hourAngle = degreesToRadians(hoursFloat/12.0 * 360.0)
        let twentyFourHoursAngle = degreesToRadians(twentyFourHoursFloat/24.0 * 360.0)
        
        if self.face == .melting
        {
            let secScaleTransform = CGAffineTransform(scaleX: 1.0, y: abs(cos(secAngle)) * 0.25 + 0.75)
            let minScaleTransform = CGAffineTransform(scaleX: 1.0, y: abs(cos(minAngle)) * 0.25 + 0.75)
            let hourScaleTransform = CGAffineTransform(scaleX: 1.0, y: abs(cos(hourAngle)) * 0.25 + 0.75)
            
            secAngle  += degreesToRadians(-55.0)
            minAngle  += degreesToRadians(-55.0)
            hourAngle += degreesToRadians(-55.0)
            
            self.secHand.transform = secScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: secAngle))
            self.minHand.transform = minScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: minAngle))
            self.hourHand.transform = hourScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: hourAngle))
            self.secondHandImageView?.transform = secScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: secAngle))
            self.minuteHandImageView?.transform = minScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: minAngle))
            self.hourHandImageView?.transform = hourScaleTransform.concatenating(CGAffineTransform.identity.rotated(by: hourAngle))
        }
        else if self.face != .flip
        {
            self.secHand.transform = CGAffineTransform.identity.rotated(by: secAngle)
            self.minHand.transform = CGAffineTransform.identity.rotated(by: minAngle)
            self.hourHand.transform = CGAffineTransform.identity.rotated(by: hourAngle)
            self.secondHandImageView?.transform = CGAffineTransform.identity.rotated(by: secAngle)
            self.minuteHandImageView?.transform = CGAffineTransform.identity.rotated(by: minAngle)
            self.hourHandImageView?.transform = CGAffineTransform.identity.rotated(by: hourAngle)
            if self.face == .zulu
            {
                self.hourHand.transform = CGAffineTransform.identity.rotated(by: twentyFourHoursAngle)
                self.hourHandImageView?.transform = CGAffineTransform.identity.rotated(by: twentyFourHoursAngle)
            }
        }
        else
        {
            let flipClockFace = self.clockFace as! BGFlipClockFaceView
            if (flipClockFace.hour != hours || flipClockFace.hour == nil) && !flipClockFace.hourAnimating
            {
                flipClockFace.hourAnimating = true
                flipClockFace.animateHourFlipWithHour(hours!)
            }
            if (flipClockFace.minutes != minutes || flipClockFace.minutes == nil) && !flipClockFace.minuteAnimating
            {
                flipClockFace.minuteAnimating = true
                flipClockFace.animateMinuteFlipWithMinute(minutes!)
            }
        }
        if self.face == .chrono
        {
            self.dateLabel?.text = weekdayStringForWeekday(weekday!) + " \(day ?? 0)"
        }
        else
        {
            self.dateLabel?.text = "\((day ?? 0))"
        }
    }
    
    fileprivate func weekdayStringForWeekday(_ weekday:Int) -> String
    {
        switch (weekday) {
        case 1:
            return "SUN";
        case 2:
            return "MON";
        case 3:
            return "TUE";
        case 4:
            return "WED";
        case 5:
            return "THU";
        case 6:
            return "FRI";
        case 7:
            return "SAT";
        default:
            return "";
        }
    }
    
    fileprivate func degreesToRadians(_ degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat.pi / 180.0
    }
    
}

//MARK: - Apple Watch
private class BGSimpleClockFaceView: BGClockFaceView
{
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func drawFace()
    {
        
        self.drawSecondTicksWithPercentLength(0.025, percentWidth: 0.005,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.045, percentWidth: 0.01,percentFontSize:0.05,tickColor: minuteTickColor,fontColor: textColor)
    }
    
    func drawMinuteTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            let font = self.faceFont!.withSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let verticalBuffer = self.bounds.size.height*0.01
            let horizontalBuffer = self.bounds.size.width*0.025
            
            if (360.0/12.0*CGFloat(index)).truncatingRemainder(dividingBy: 30.0) == 0
            {
                switch (360.0/12.0*CGFloat(index))/30.0{
                case 1.0:
                    let numberString:NSString = "25"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: 0.0, y: 1.0*(percentLength*self.bounds.size.height+verticalBuffer)-numberSize.height)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 2.0:
                    let numberString:NSString = "20"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: 0.0, y: 1.0*(percentLength*self.bounds.size.height+verticalBuffer)-numberSize.height)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 4.0:
                    let numberString:NSString = "10"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: 0.0, y: -numberSize.height+verticalBuffer)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 5.0:
                    let numberString:NSString = "05"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: 0.0, y: -numberSize.height+verticalBuffer)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 7.0:
                    let numberString:NSString = "55"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+horizontalBuffer, y: -numberSize.height)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 8.0:
                    let numberString:NSString = "50"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+verticalBuffer, y: -numberSize.height)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 10.0:
                    let numberString:NSString = "40"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+verticalBuffer, y: -verticalBuffer)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 11.0:
                    let numberString:NSString = "35"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+verticalBuffer, y: -verticalBuffer)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(in: rect, withAttributes: textFontAttributes)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                    
                default:
                    break
                }
            }
            
            context?.rotate(by: self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: -verticalBuffer))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength-verticalBuffer))
            path.lineWidth = self.bounds.size.width * percentWidth;
            
            tickColor.setStroke()
            tickColor.setFill()
            
            path.stroke()
            
            let roundRectRect = CGRect(x: -self.bounds.size.width * percentWidth*1.25, y: (self.bounds.size.width * -percentLength)-(verticalBuffer*4.0)-(self.bounds.size.width * percentLength*3.0), width: self.bounds.size.width * percentWidth*2.5, height: self.bounds.size.width * percentLength*3.0)
            let roundRect = UIBezierPath(roundedRect: roundRectRect, cornerRadius: self.bounds.size.width * percentWidth*1.25)
            roundRect.stroke()
            roundRect.fill()
            
            context?.restoreGState();
        }
    }
    
    func drawSecondTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let verticalBuffer = self.bounds.size.height*0.01
        
        for i in 0...119{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/120.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/120.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            
            context?.translateBy(x: translateX, y: translateY)
            context?.rotate(by: self.degreesToRadians(-360.0/120.0*CGFloat(i)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: -verticalBuffer))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength-verticalBuffer))
            path.lineWidth = self.bounds.size.width * percentWidth;
            color.setStroke()
            path.stroke()
            context?.restoreGState();
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        self.drawFace()
    }
}

private class BGNormalClockFaceView: BGClockFaceView
{
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func drawFace()
    {
        
        self.drawSecondTicksWithPercentLength(0.05, percentWidth: 0.005,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.05, percentWidth: 0.015,percentFontSize:0.15,tickColor: minuteTickColor,fontColor: textColor)
    }
    
    func drawMinuteTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            let font = self.faceFont!.withSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let verticalBuffer = self.bounds.size.height*0.01
            let horizontalBuffer = self.bounds.size.width*0.025
            
            if (360.0/12.0*CGFloat(index)).truncatingRemainder(dividingBy: 90.0) == 0
            {
                switch (360.0/12.0*CGFloat(index))/90.0{
                case 0.0:
                    let numberString:NSString = "6"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: 0.0-numberSize.width*0.5, y: -1.0*(percentLength*self.bounds.size.height+verticalBuffer)-numberSize.height)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 1.0:
                    let numberString:NSString = "3"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x:-1.0*(percentLength*self.bounds.size.width+horizontalBuffer)-numberSize.width , y:-numberSize.height*0.5 )
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 2.0:
                    let numberString:NSString = "12"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x: 0.0-numberSize.width*0.5, y: percentLength*self.bounds.size.height+verticalBuffer)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 3.0:
                    let numberString:NSString = "9"
                    let numberSize = numberString.size(attributes: textFontAttributes)
                    let point = CGPoint(x:1.0*(percentLength*self.bounds.size.width+horizontalBuffer), y:0.0-numberSize.height*0.5)
                    var rect = CGRect.zero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                default:
                    break
                }
            }
            
            context?.rotate(by: self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: 0.0))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
            path.lineWidth = self.bounds.size.width * percentWidth;
            tickColor.setStroke()
            path.stroke()
            context?.restoreGState();
        }
    }
    
    func drawSecondTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        for i in 0...59{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            
            context?.translateBy(x: translateX, y: translateY)
            context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(i)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: 0.0))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
            path.lineWidth = self.bounds.size.width * percentWidth;
            color.setStroke()
            path.stroke()
            context?.restoreGState();
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        self.drawFace()
    }
}


private class BGUtilityClockFaceView: BGClockFaceView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func drawFace()
    {
        
        self.drawSecondTicksWithPercentLength(0.04, percentWidth: 0.004,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.0, percentWidth: 0.00,percentFontSize:0.041,tickColor: minuteTickColor,fontColor: self.textColor)
    }
    
    func drawMinuteTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        self.drawLargeNumbers(percentFontSize, fontColor: fontColor,percentInset: 0.13)
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            
            let angle = 360.0/12.0*CGFloat(index)

            let translateX = sin(self.degreesToRadians(angle))*self.frame.size.width*0.48+self.frame.size.width*0.505
            let translateY = cos(degreesToRadians(angle))*self.frame.size.width*0.48+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            let font = self.faceFont!.withSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: minuteTickColor,
                NSParagraphStyleAttributeName: textStyle
            ] as [String : Any]
            let numberSize = "     ".size(attributes: textFontAttributes)

            if angle.truncatingRemainder(dividingBy: 30.0) == 0
            {
                switch angle/30.0{
                case 0.0:
                    let numberString:NSString = "30"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 1.0:
                    let numberString:NSString = "25"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 2.0:
                    let numberString:NSString = "20"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                case 3.0:
                    let numberString:NSString = "15"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 4.0:
                    let numberString:NSString = "10"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 5.0:
                    let numberString:NSString = "05"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 6.0:
                    let numberString:NSString = "60"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 7.0:
                    let numberString:NSString = "55"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 8.0:
                    let numberString:NSString = "50"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 9.0:
                    let numberString:NSString = "45"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 10.0:
                    let numberString:NSString = "40"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                case 11.0:
                    let numberString:NSString = "35"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.draw(at: point, withAttributes: textFontAttributes)
                    break
                default:
                    break
                }
            }
            
            context?.rotate(by: self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            context?.restoreGState();
        }
    }
    
    func drawSecondTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        
        for i in 0...59{
            if i % 5 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                context?.saveGState();
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                context?.translateBy(x: translateX, y: translateY)
                context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0.0,y: 0.0))
                path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
                path.lineWidth = self.bounds.size.width * percentWidth;
                color.setStroke()
                path.stroke()
                context?.restoreGState();
            }
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        self.drawFace()
    }
    
    func drawLargeNumbers(_ percentFontSize:CGFloat,fontColor:UIColor,percentInset:CGFloat)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            
            let largeFont = self.faceFont!.withSize(self.bounds.size.height * percentFontSize*2.75)
            let largeTextFontAttributes = [
                NSFontAttributeName: largeFont,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let angle = 360.0/12.0*CGFloat(index)
            let largeNumberSize = "      ".size(attributes: largeTextFontAttributes)
            if angle.truncatingRemainder(dividingBy: 30.0) == 0
            {
                switch angle/30.0{
                case 0.0:
                    
                    let largeNumberString:NSString = "6"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 1.0:
                    
                    let largeNumberString:NSString = "5"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 2.0:
                    
                    let largeNumberString:NSString = "4"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 3.0:
                    
                    let largeNumberString:NSString = "3"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 4.0:
                    
                    let largeNumberString:NSString = "2"
                    
                    //let largeOffsetPoint = self.trigOffsetForAngle(angle, size: largeNumberOffset)
                    //let largeNumberPoint = CGPoint(x: -largeOffsetPoint.x, y: -largeOffsetPoint.y)
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 5.0:
                    
                    let largeNumberString:NSString = "1"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 6.0:
                    
                    let largeNumberString:NSString = "12"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 7.0:
                    
                    let largeNumberString:NSString = "11"
                
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    
                    break
                case 8.0:
                    
                    let largeNumberString:NSString = "10"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 9.0:
                    
                    let largeNumberString:NSString = "9"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 10.0:
                    
                    let largeNumberString:NSString = "8"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 11.0:
                    
                    let largeNumberString:NSString = "7"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                    
                default:
                    break
                }
            }
            
            context?.rotate(by: self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            
            
            context?.restoreGState();
        }

    }
    
    func trigSquareOffsetForAngle(_ angle:CGFloat,width:CGFloat) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*width*0.5+width*0.5
        let y = cos(degreesToRadians(angle))*width*0.5+width*0.5
        return CGPoint(x: x, y: y)
    }
    
    func trigOffsetForAngle(_ angle:CGFloat,size:CGSize) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*size.width*0.5+size.width*0.5
        let y = cos(degreesToRadians(angle))*size.height*0.5+size.height*0.5
        return CGPoint(x: x, y: y)
    }
    
}

private class BGAppleWatchClockSecondHandView: BGClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.60, percentWidth: 0.01,color:self.handColor)
        
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalIn: screwRect)
        self.handColor.setStroke()
        self.handColor.setFill()
        
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalIn: screwRect.insetBy(dx: screwRadius*0.5, dy: screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
        
    }
}

private class BGAppleWatchClockMinuteHandView: BGAppleWatchClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.040,color:self.handColor)
    }
}

private class BGAppleWatchClockHourHandView: BGAppleWatchClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.040,color: self.handColor)
    }
}

private class BGAppleWatchClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let linePercentLength:CGFloat = 0.08
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalIn:centerScrewRect)
        path.append(screwCircle)
        
        let line = UIBezierPath(rect: CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.25, y: self.bounds.size.height*0.5-self.bounds.size.height*(linePercentLength+0.02), width: self.bounds.size.width*percentWidth*0.5, height: self.bounds.size.height*(linePercentLength+0.02)))
        path.append(line)
        
        let roundedRectRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.width*0.5-handLength, width: self.bounds.size.width*percentWidth, height: handLength-self.bounds.size.height*linePercentLength)
        let roundedRect = UIBezierPath(roundedRect: roundedRectRect, cornerRadius: self.bounds.size.width*percentWidth*0.5)
        path.append(roundedRect)
        
        color.setFill()
        color.setStroke()
        path.stroke()
        path.fill()
    }
}

//MARK: - Square

private class BGSquareClockFaceView: BGClockFaceView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func drawFace()
    {
        let percentFontSize:CGFloat = 0.15
        let font = self.faceFont!.withSize(self.bounds.size.height * percentFontSize)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: minuteTickColor,
            NSParagraphStyleAttributeName: textStyle
        ] as [String : Any]
        
        let horizontalSpacing = self.frame.size.height * 0.35
        let verticalSpacing = self.frame.size.height * 0.15
        let numberSize = "      ".size(attributes: textFontAttributes)
        let verticalBuffer = self.frame.size.height * 0.03
        let horizontalBuffer = self.frame.size.height * -0.04
        
        for index in 11...13
        {
            var numberString:NSString = String(index) as NSString
            if index == 11
            {
                numberString = "1"
            }
            else if index == 13
            {
                numberString = "11"
            }
            let spacingNumber = horizontalSpacing * (CGFloat(index) - 12.0)
            let x = self.bounds.size.width * 0.5 - spacingNumber + numberSize.width * (0.5 * CGFloat(index) - 6.5)
            let point = CGPoint(x: x, y: verticalBuffer)
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.draw(in: rect, withAttributes: textFontAttributes)
        }
        for index in 2...4
        {
            let numberString:NSString = String(index) as NSString
            let point = CGPoint(x: self.bounds.size.width - numberSize.width - horizontalBuffer , y: self.bounds.size.height * 0.5 + verticalSpacing * (CGFloat(index) - 3) + numberSize.height * (0.5 * CGFloat(index) - 2.0))
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.draw(in: rect, withAttributes: textFontAttributes)
        }
        for index in 5...7
        {
            let numberString:NSString = String(index) as NSString
            let widthNumber = (0.5 * CGFloat(index) - 3.5)
            let horizontalNumber = CGFloat(index) - 6
            let x = self.bounds.size.width * 0.5 - horizontalSpacing * horizontalNumber + numberSize.width * widthNumber
            let point = CGPoint(x: x, y: self.bounds.size.height - verticalBuffer - numberSize.height)
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.draw(in: rect, withAttributes: textFontAttributes)
        }
        for index in 8...10
        {
            let numberString:NSString
            numberString = String(index) as NSString
            let point = CGPoint(x:horizontalBuffer , y: self.bounds.size.height * 0.5 + verticalSpacing * (CGFloat(-index) + 9) + numberSize.height * (-0.5 * CGFloat(index) + 4))
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.draw(in: rect, withAttributes: textFontAttributes)
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        self.drawFace()
    }
}


//MARK: - Chrono

private class BGChronoClockFaceView : BGUtilityClockFaceView {
    override func drawFace()
    {
        self.drawLargeNumbers(0.035, fontColor: self.textColor, percentInset: 0.10)
        self.drawSecondTicksWithPercentLength(0.04, percentWidth: 0.004,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.4, percentWidth: 0.0004,percentFontSize:0.00,tickColor: minuteTickColor,fontColor: UIColor.clear)
        self.drawMilliSecondTicksWithPercentLength(0.02, percentWidth: 0.004, color: secondTickColor)
        self.drawTopAndBottomDialsWithPercentLength(0.01, percentWidth: 0.004, percentFontSize: 0.035, tickColor: secondTickColor, fontColor: textColor)
    }
    
    func drawTopAndBottomDialsWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        let font = self.faceFont!.withSize(self.bounds.size.height * percentFontSize)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        for i in 0...1 {
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let firstTranslateY =  (i == 0) ? self.frame.size.height * 0.20 : self.frame.size.height * 0.55
            context?.translateBy(x: 0.0, y: firstTranslateY)
            let handWidth = self.bounds.size.width * 0.0025
            let circle = UIBezierPath(ovalIn:CGRect(x: self.bounds.size.width * 0.5 - handWidth * 3.0, y: self.frame.size.width*0.12, width: handWidth * 6.0, height: handWidth * 6.0))
            tickColor.setFill()
            tickColor.setStroke()
            circle.stroke()
            circle.fill()
            
            let rect = UIBezierPath(rect: CGRect(x: self.bounds.size.width * 0.5 - handWidth * 0.5, y: self.frame.size.width*0.12, width: handWidth, height: -self.frame.size.width*0.12))
            rect.stroke()
            rect.fill()
            
            for index in 0...59
            {
                context?.saveGState();
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(index)))*self.frame.size.width*0.12+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(index)))*self.frame.size.width*0.12+self.frame.size.width*0.12
                let angle = 360.0/60.0*CGFloat(index)
                let verticalBuffer = -self.frame.size.width * 0.125 * 0.15
                context?.translateBy(x: translateX, y: translateY)
                if angle.truncatingRemainder(dividingBy: 90.0) == 0 && i == 1
                {
                    switch angle/90.0{
                    case 0.0:
                        let numberString:NSString = "30"
                        let numberSize = numberString.size(attributes: textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y: -y)
                        
                        numberString.draw(at: point, withAttributes: textFontAttributes)
                        
                        break
                    case 1.0:
                        
                        let numberString:NSString = "15"
                        let numberSize = numberString.size(attributes: textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        numberString.draw(at: point, withAttributes: textFontAttributes)
                        
                        break
                    case 2.0:
                        
                        let numberString:NSString = "60"
                        let numberSize = numberString.size(attributes: textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(360.0/12.0*CGFloat(index), width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        
                        numberString.draw(at: point, withAttributes: textFontAttributes)
                        
                    case 3.0:
                        
                        let numberString:NSString = "45"
                        let numberSize = numberString.size(attributes: textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(360.0/12.0*CGFloat(index), width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        numberString.draw(at: point, withAttributes: textFontAttributes)
                        
                        break
                        
                    default:
                        break
                    }
                }
                if angle.truncatingRemainder(dividingBy: 180.0) == 0 && i == 0
                {
                    switch angle/180.0{
                    case 0.0:
                        let numberString:NSString = "1"
                        let numberSize = numberString.size(attributes: textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y: y + verticalBuffer * 3.0)
                        
                        numberString.draw(at: point, withAttributes: textFontAttributes)
                        
                        break
                    case 1.0:
                        
                        let numberString:NSString = "2"
                        let numberSize = numberString.size(attributes: textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        numberString.draw(at: point, withAttributes: textFontAttributes)
                        
                        break
                    default:
                        break
                    }
                }

                
                context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(index)))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0.0,y: -verticalBuffer))
                if index % 2 == 0
                {
                    path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength - verticalBuffer))
                }
                else
                {
                    path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength * 2.0 - verticalBuffer))

                }
                path.lineWidth = self.bounds.size.width * percentWidth;
                tickColor.setStroke()
                path.stroke()
                
                context?.restoreGState();
            }
            context?.restoreGState();
            
            
        }
    }
    
    func drawMilliSecondTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        for i in 0...299{
            if i % 25 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                context?.saveGState();
                let translateX = sin(self.degreesToRadians(360.0/300.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/300.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                context?.translateBy(x: translateX, y: translateY)
                context?.rotate(by: self.degreesToRadians(-360.0/300.0*CGFloat(i)))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0.0,y: 0.0))
                path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
                path.lineWidth = self.bounds.size.width * percentWidth;
                color.setStroke()
                path.stroke()
                context?.restoreGState();
            }
            else
            {
                let context = UIGraphicsGetCurrentContext();
                context?.saveGState();
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                context?.translateBy(x: translateX, y: translateY)
                context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0.0,y: 0.0))
                path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength * 2.0))
                path.lineWidth = self.bounds.size.width * percentWidth * 2.0;
                self.minuteTickColor.setStroke()
                path.stroke()
                context?.restoreGState();
            }
        }

    }
}

private class BGAppleWatchChronoClockMinuteHandView: BGAppleWatchChronoClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.040,color:self.handColor)
    }
}

private class BGAppleWatchChronoClockHourHandView: BGAppleWatchChronoClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.040,color: self.handColor)
    }
}

private class BGAppleWatchChronoClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();

        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let linePercentLength:CGFloat = 0.08
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalIn:centerScrewRect)
        path.append(screwCircle)
        
        let line = UIBezierPath(rect: CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.25, y: self.bounds.size.height*0.5-self.bounds.size.height*(linePercentLength), width: self.bounds.size.width*percentWidth*0.5, height: self.bounds.size.height*(linePercentLength+0.02)))
        path.append(line)
        
        let roundedRectRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.width*0.5-handLength, width: self.bounds.size.width*percentWidth, height: handLength-self.bounds.size.height*linePercentLength)
        let roundedRect = UIBezierPath(roundedRect: roundedRectRect, cornerRadius: self.bounds.size.width*percentWidth*0.5)
        roundedRect.lineWidth = self.bounds.size.width * percentWidth * 0.25
        
        color.setFill()
        color.setStroke()
        path.stroke()
        path.fill()
        roundedRect.stroke()
    }
}

//MARK: - 24Hour

private class BG24HourClockFaceView: BGUtilityClockFaceView {
    override func drawFace()
    {
        self.drawMinuteTicksWithPercentLength(0.08, percentWidth: 0.004,percentFontSize:0.02,tickColor: self.minuteTickColor,fontColor: textColor)
        self.drawSecondTicksWithPercentLength(0.04,percentWidth: 0.004,color: self.secondTickColor)
    }
    
    override func drawMinuteTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        self.drawLargeNumbers(percentFontSize, fontColor: fontColor,percentInset: 0.00)
        
        for i in 0...11{
            
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
            
            context?.translateBy(x: translateX, y: translateY)
            context?.rotate(by: self.degreesToRadians(-360.0/12.0*CGFloat(i)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: 0.0))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
            path.lineWidth = self.bounds.size.width * percentWidth;
            tickColor.setStroke()
            path.stroke()
            context?.restoreGState();
            
        }
    }
    
    override func drawLargeNumbers(_ percentFontSize:CGFloat,fontColor:UIColor,percentInset:CGFloat)
    {
        for index in 0...23 {
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            
            let angle = 360.0/24.0*CGFloat(index)

            let translateX = sin(self.degreesToRadians(angle))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(angle - 180.0))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            
            let largeFont = self.faceFont!.withSize(self.bounds.size.height * percentFontSize*2.75)
            let largeTextFontAttributes = [
                NSFontAttributeName: largeFont,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let largeNumberSize = "     ".size(attributes: largeTextFontAttributes)
            context?.rotate(by: self.degreesToRadians(angle))
            
            var largeNumberString:NSString
            if angle / 15.0 == 0
            {
                largeNumberString = "24"
            }
            else
            {
                largeNumberString = String(abs(Int(angle / 15.0))) as NSString
            }
            
            
            let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.00)
            
            largeNumberString.draw(in: CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
            
            context?.restoreGState();
        }
        
    }
    
    override func drawSecondTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        
        for i in 0...59{
            if i % 5 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                context?.saveGState();
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
                
                context?.translateBy(x: translateX, y: translateY)
                context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0.0,y: 0.0))
                path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
                path.lineWidth = self.bounds.size.width * percentWidth;
                color.setStroke()
                path.stroke()
                context?.restoreGState();
            }
        }
    }

}

//MARK: - Plain

private class BGPlainClockFaceView: BGUtilityClockFaceView {
    override func drawFace()
    {
        self.drawMinuteTicksWithPercentLength(0.00, percentWidth: 0.000,percentFontSize:0.05,tickColor: UIColor.clear,fontColor: textColor)
    }
    
    override func drawMinuteTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        self.drawLargeNumbers(percentFontSize, fontColor: fontColor,percentInset: 0.085)
    }
}

private class BGPlainClockMinuteHandView: BGPlainClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.015,color:self.handColor)
    }
}

private class BGPlainClockHourHandView: BGPlainClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.015,color: self.handColor)
    }
}

private class BGPlainClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth * 1.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth * 1.5, width: self.bounds.size.width*percentWidth * 3.0, height: self.bounds.size.width*percentWidth * 3.0)
        let screwCircle = UIBezierPath(ovalIn:centerScrewRect)
        path.append(screwCircle)
        
        let roundedRectRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.width*0.5-handLength, width: self.bounds.size.width*percentWidth, height: handLength)
        let roundedRect = UIBezierPath(roundedRect: roundedRectRect, cornerRadius: self.bounds.size.width*percentWidth*0.5)
        path.append(roundedRect)
        
        color.setFill()
        color.setStroke()
        path.stroke()
        path.fill()
    }
}

//MARK: - Minimal

private class BGMinimalClockFaceView: BGNormalClockFaceView {
    override func drawFace()
    {
        let circle = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width * 0.25, dy: self.bounds.size.height * 0.25))
        self.minuteTickColor.setFill()
        self.minuteTickColor.setStroke()
        circle.stroke()
        circle.fill()
        
        self.drawMinuteTicksWithPercentLength(0.00, percentWidth: 0.000,percentFontSize:0.15,tickColor: minuteTickColor,fontColor: textColor)
    }
    
    override func drawMinuteTicksWithPercentLength(_ percentLength: CGFloat, percentWidth: CGFloat, percentFontSize: CGFloat, tickColor: UIColor, fontColor: UIColor) {
        super.drawMinuteTicksWithPercentLength(percentLength, percentWidth: percentWidth, percentFontSize: percentFontSize, tickColor: tickColor, fontColor: fontColor)
        
        let circleWidth = self.bounds.size.width * percentFontSize * 0.25
        
        for index in 0...11 {
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            let angle = 360.0/12.0*CGFloat(index)
            if angle.truncatingRemainder(dividingBy: 90.0) != 0.0
            {
                if angle < 90.0
                {
                    let circle2 = UIBezierPath(ovalIn: CGRect(x: -circleWidth, y: -circleWidth , width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
                else if angle < 180.0 && angle > 90.0
                {
                    let circle2 = UIBezierPath(ovalIn: CGRect(x: -circleWidth * 0.5, y: circleWidth * 0.5, width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
                else if angle < 270.0 && angle > 180.0
                {
                    let circle2 = UIBezierPath(ovalIn: CGRect(x: circleWidth * 0.5, y: circleWidth * 0.5, width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
                else
                {
                    let circle2 = UIBezierPath(ovalIn: CGRect(x: circleWidth * 0.5, y: -circleWidth, width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
            }
            context?.restoreGState()
        }
    }
}

private class BGMinimalClockSecondHandView: BGMinimalClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.47, percentWidth: 0.01,color:self.handColor)
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalIn: screwRect)
        self.handColor.setStroke()
        self.handColor.setFill()
        
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalIn: screwRect.insetBy(dx: screwRadius*0.5, dy: screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
        
    }
}

private class BGMinimalClockMinuteHandView: BGMinimalClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.47, percentWidth: 0.015,color:self.handColor)
    }
}

private class BGMinimalClockHourHandView: BGMinimalClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.015,color: self.handColor)
    }
}

private class BGMinimalClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let lineWidth = self.bounds.size.width*percentWidth
        
        let tapperFactor = self.bounds.size.width * 0.005
        let stub = self.bounds.size.height * 0.03
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalIn:centerScrewRect)
        path.append(screwCircle)
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: self.bounds.size.width*0.5 - lineWidth, y: self.bounds.size.height*0.5 + stub - tapperFactor))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor, y: self.bounds.size.height*0.5 + stub), controlPoint: CGPoint(x: self.bounds.size.width*0.5 - lineWidth, y: self.bounds.size.height*0.5 + stub))
        line.addLine(to: CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor, y: self.bounds.size.height*0.5 + stub))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5 + lineWidth, y: self.bounds.size.height*0.5 + stub - tapperFactor), controlPoint: CGPoint(x: self.bounds.size.width*0.5 + lineWidth, y: self.bounds.size.height*0.5 + stub))
        line.addLine(to: CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor, y: self.bounds.size.height*0.5 - handLength + tapperFactor))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor * 2.0, y: self.bounds.size.height*0.5 - handLength ), controlPoint: CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor, y: self.bounds.size.height*0.5 - handLength))
        line.addLine(to: CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor * 2.0, y: self.bounds.size.height*0.5 - handLength))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor, y: self.bounds.size.height*0.5 - handLength + tapperFactor), controlPoint: CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor, y: self.bounds.size.height*0.5 - handLength))
        line.close()
        
        color.setFill()
        color.setStroke()
        path.stroke()
        path.fill()
        line.stroke()
        line.fill()
    }
}


//MARK: - Big Ben

private class BGBigBenClockMinuteHandView: BGBigBenClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.46, percentWidth: 0.045,color:self.handColor)
    }
}

private class BGBigBenClockHourHandView: BGBigBenClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.045,color: self.handColor)
    }
}

private class BGBigBenClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        color.setFill()
        color.setStroke()
        let context = UIGraphicsGetCurrentContext();
        context?.saveGState();
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let fanRadius = self.bounds.size.width*percentWidth*2.0
        let verticalBuffer = self.bounds.size.width*0.02
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.width*0.5+fanRadius))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5+fanRadius*0.5,
            y: self.bounds.size.width*0.5+fanRadius),
            controlPoint: CGPoint(x: self.bounds.size.width*0.5+fanRadius*0.25,
                y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5+self.bounds.size.width*percentWidth*0.5*0.40, y: self.bounds.size.width*0.5), controlPoint: CGPoint(x: self.bounds.size.width*0.5+fanRadius*0.25, y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.addLine(to: CGPoint(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5*0.40, y: self.bounds.size.width*0.5))
        line.addQuadCurve(to: CGPoint(x:self.bounds.size.width*0.5-fanRadius*0.5, y: self.bounds.size.width*0.5+fanRadius), controlPoint: CGPoint(x: self.bounds.size.width*0.5-fanRadius*0.25, y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.addQuadCurve(to: CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.width*0.5+fanRadius), controlPoint: CGPoint(x: self.bounds.size.width*0.5-fanRadius*0.25, y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.close()
        
        line.stroke()
        line.fill()
        
        let line2 = UIBezierPath()
        line2.move(to: CGPoint(x: self.bounds.size.width*0.5-self.bounds.size.width*0.4*percentWidth, y: self.bounds.size.height*0.5))
        line2.addLine(to: CGPoint(x: self.bounds.size.width*0.5-self.bounds.size.width*0.25*percentWidth, y: self.bounds.size.height*0.5-handLength+self.bounds.size.width*0.5*percentWidth))
        line2.addLine(to: CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.5-handLength))
        line2.addLine(to: CGPoint(x: self.bounds.size.width*0.5+self.bounds.size.width*0.25*percentWidth, y: self.bounds.size.height*0.5-handLength+self.bounds.size.width*0.5*percentWidth))
        line2.addLine(to: CGPoint(x: self.bounds.size.width*0.5+self.bounds.size.width*percentWidth*0.4, y: self.bounds.size.height*0.5))
        line2.stroke()
        line2.fill()

        context?.restoreGState()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5*1.25, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5*1.25, width: self.bounds.size.width*percentWidth*1.25, height: self.bounds.size.width*percentWidth*1.2)
        let screwCircle = UIBezierPath(ovalIn:centerScrewRect)
        screwCircle.stroke()
        screwCircle.fill()
        
    }
}


private class BGBigBenClockFaceView: BGClockFaceView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func drawFace()
    {
        self.textColor.setStroke()
        
        let circle = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width*0.02, dy: self.bounds.size.height*0.02))
        circle.lineWidth = self.bounds.size.width*0.04
        circle.stroke()
        
        let circle2 = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width*0.07, dy: self.bounds.size.height*0.07))
        circle2.lineWidth = self.bounds.size.width*0.01
        circle2.stroke()
        
        let circle3 = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width*0.14, dy: self.bounds.size.height*0.14))
        circle3.lineWidth = self.bounds.size.width*0.01
        circle3.stroke()
        
        let circle4 = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width*0.17, dy: self.bounds.size.height*0.17))
        circle4.lineWidth = self.bounds.size.width*0.0125
        circle4.stroke()
        
        let circle5 = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width*0.25, dy: self.bounds.size.height*0.25))
        circle5.lineWidth = self.bounds.size.width*0.01
        circle5.stroke()
        
        let circle6 = UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.bounds.size.width*0.27, dy: self.bounds.size.height*0.27))
        circle6.lineWidth = self.bounds.size.width*0.01
        circle6.stroke()
        
        self.drawSecondTicksWithPercentLength(0.04, percentWidth: 0.010,color: self.secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.0, percentWidth: 0.00,percentFontSize:0.08,tickColor: minuteTickColor,fontColor: self.textColor)
    }
    
    func drawMinuteTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            let font = self.faceFont!.withSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let verticalBuffer = self.bounds.size.height*0.01
            let angle = 360.0/12.0*CGFloat(index)
            
            
            context?.rotate(by: self.degreesToRadians(-angle+180.0))
            var numberString:NSString = ""
            switch angle/30.0 {
            case 0:
                numberString = "VI"
                break
            case 1:
                numberString = "V"
                break
            case 2:
                numberString = "IV"
                break
            case 3:
                numberString = "III"
                break
            case 4:
                numberString = "II"
                break
            case 5:
                numberString = "I"
                break
            case 6:
                numberString = "XII"
                break
            case 7:
                numberString = "XI"
                break
            case 8:
                numberString = "X"
                break
            case 9:
                numberString = "IX"
                break
            case 10:
                numberString = "VIII"
                break
            case 11:
                numberString = "VII"
                break
            default:
                break
            }
            
            let numberSize = numberString.size(attributes: textFontAttributes)
            let point = CGPoint(x: -numberSize.width*0.5, y: self.bounds.size.height*0.08-verticalBuffer+numberSize.height)
            numberString.draw(at: point, withAttributes: textFontAttributes)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: self.bounds.size.width*0.04))
            path.addLine(to: CGPoint(x: -verticalBuffer,y: self.bounds.size.width*0.04+verticalBuffer))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width*0.04+verticalBuffer*2.0))
            path.addLine(to: CGPoint(x: verticalBuffer,y: self.bounds.size.width*0.04+verticalBuffer))
            path.close()
            path.lineWidth = self.bounds.size.width * percentWidth;
            
            let rect = UIBezierPath(rect: CGRect(x: -verticalBuffer, y: self.bounds.size.width*0.04+verticalBuffer*2.0, width: verticalBuffer*2.0, height: self.bounds.size.height*0.09))
            path.append(rect)
            
            let path2 = UIBezierPath()
            path2.move(to: CGPoint(x: 0.0, y: self.bounds.size.width*0.04+verticalBuffer*2.0+self.bounds.size.height*0.09))
            path2.addLine(to: CGPoint(x: -verticalBuffer, y: self.bounds.size.width*0.04+verticalBuffer*3.0+self.bounds.size.height*0.09))
            path2.addLine(to: CGPoint(x: 0.0, y: self.bounds.size.width*0.04+verticalBuffer*4.0+self.bounds.size.height*0.09))
            path2.addLine(to: CGPoint(x: verticalBuffer, y: self.bounds.size.width*0.04+verticalBuffer*3.0+self.bounds.size.height*0.09))
            path2.close()
            path.append(path2)
            
            let path3 = UIBezierPath()
            path3.move(to: CGPoint(x: -verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8+verticalBuffer))
            path3.addLine(to: CGPoint(x: -verticalBuffer, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            path3.addLine(to: CGPoint(x: -verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8-verticalBuffer))
            path3.addLine(to: CGPoint(x: -verticalBuffer*3.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            
            
            path3.close()
            path.append(path3)
            
            let path4 = UIBezierPath()
            path4.move(to: CGPoint(x: verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8-verticalBuffer))
            path4.addLine(to: CGPoint(x: verticalBuffer, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            path4.addLine(to: CGPoint(x: verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8+verticalBuffer))
            path4.addLine(to: CGPoint(x: verticalBuffer*3.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            
            
            path4.close()
            path.append(path4)
            
            let path5 = UIBezierPath()
            path5.move(to: CGPoint(x: 0.0, y: verticalBuffer*2.0+self.bounds.size.height*0.23))
            path5.addLine(to: CGPoint(x: -verticalBuffer, y: verticalBuffer*3.0+self.bounds.size.height*0.23))
            path5.addLine(to: CGPoint(x: 0.0, y: verticalBuffer*4.0+self.bounds.size.height*0.23))
            path5.addLine(to: CGPoint(x: verticalBuffer, y:verticalBuffer*3.0+self.bounds.size.height*0.23))
            
            path5.close()
            path.append(path5)
            
            tickColor.setStroke()
            tickColor.setFill()
            
            path.stroke()
            path.fill()
            
            context?.restoreGState();
            
        }
        
        for index in 0...23{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let angle = 360.0/24.0*CGFloat(index)
            
            let translateX = sin(self.degreesToRadians(angle))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(angle))*self.frame.size.width*0.5+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            
            context?.rotate(by: self.degreesToRadians(-angle+180.0))
            
            let path6 = UIBezierPath()
            path6.move(to: CGPoint(x: 0.0, y: self.bounds.size.height*0.275))
            path6.addLine(to: CGPoint(x: -self.bounds.size.width*0.035, y: self.bounds.size.height*0.375))
            path6.addCurve(to: CGPoint(x: 0.0, y: self.bounds.size.height*0.5), controlPoint1: CGPoint(x: self.bounds.size.width*0.035, y: self.bounds.size.height*0.5), controlPoint2: CGPoint(x: 0.0, y: self.bounds.size.height*0.45))
            
            let path7 = UIBezierPath()
            path7.move(to: CGPoint(x: 0.0, y: self.bounds.size.height*0.275))
            path7.addLine(to: CGPoint(x: self.bounds.size.width*0.035, y: self.bounds.size.height*0.375))
            path7.addCurve(to: CGPoint(x: 0.0, y: self.bounds.size.height*0.5), controlPoint1: CGPoint(x: -self.bounds.size.width*0.035, y: self.bounds.size.height*0.5), controlPoint2: CGPoint(x: 0.0, y: self.bounds.size.height*0.45))
            path6.append(path7)
            
            tickColor.setStroke()
            tickColor.setFill()
            
            path6.lineWidth = self.bounds.size.width * 0.005
            path6.stroke()
            
            context?.restoreGState();
            
        }
    }
    
    func drawSecondTicksWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        
        for i in 0...59{
            if i % 5 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                context?.saveGState();
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                context?.translateBy(x: translateX, y: translateY)
                context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0.0,y: -self.bounds.size.height*0.15))
                path.addLine(to: CGPoint(x: 0.0,y: -self.bounds.size.height*0.06))
                path.lineWidth = self.bounds.size.width * percentWidth;
                path.lineCapStyle = .round
                color.setStroke()
                path.stroke()
                context?.restoreGState();
            }
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        self.drawFace()
    }
    
    func trigSquareOffsetForAngle(_ angle:CGFloat,width:CGFloat) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*width*0.5+width*0.5
        let y = cos(degreesToRadians(angle))*width*0.5+width*0.5
        return CGPoint(x: x, y: y)
    }
    
    func trigOffsetForAngle(_ angle:CGFloat,size:CGSize) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*size.width*0.5+size.width*0.5
        let y = cos(degreesToRadians(angle))*size.height*0.5+size.height*0.5
        return CGPoint(x: x, y: y)
    }
}

//MARK: - Flip
private class BGFlipClockFaceView: BGClockFaceView
{
    var hourNumberView:BGFlipNumberView
    var minuteNumberView:BGFlipNumberView
    var amPMLabel = UILabel(frame: CGRect.zero)
    var minuteAnimating = false
    var hourAnimating = false
    
    var buffer:CGFloat {
        get{
            return self.bounds.size.width * 0.03
        }
    }
    
    var squareHeight:CGFloat{
        get{
            return (self.bounds.size.width - buffer * 3.0) * 0.5
        }
    }
    
    var font:UIFont{
        get{
            if self.faceFont == nil
            {
                self.faceFont = UIFont.systemFont(ofSize: squareHeight * 0.80)
            }
            return self.faceFont!.withSize(squareHeight * 0.80)
        }
    }
    
    var amPMFont:UIFont{
        get{
            if self.faceFont == nil
            {
                self.faceFont = UIFont.systemFont(ofSize: squareHeight * 0.80 * 0.20)
            }
            return self.faceFont!.withSize(squareHeight * 0.80 * 0.20)
        }
    }
    
    var amPMFontAttributes:[String:AnyObject]{
        get{
            return [
                NSFontAttributeName: amPMFont,
                NSForegroundColorAttributeName: self.textColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
        }
    }
    
    var textStyle:NSMutableParagraphStyle{
        get{
            let tS = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            tS.alignment = NSTextAlignment.center
            return tS
        }
    }
    
    var textFontAttributes:[String:AnyObject]{
        get{
            return [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: self.textColor,
                NSParagraphStyleAttributeName: textStyle
            ]

        }
    }
    
    override var frame: CGRect {
        didSet {
            self.updateFrames()
        }
    }

    var hour:Int?{
        didSet{
            
            if self.hour != nil
            {
                var hString = self.hour>12 ? "\(self.hour! - 12)" : "\(self.hour!)"
                if self.hour == 0
                {
                    hString = "12"
                }
                let hourString = NSAttributedString(string: hString, attributes: textFontAttributes)
                self.hourNumberView.numberString = hourString
                
                let amString:NSString = self.hour! > 12 ? NSString(string: "PM") : NSString(string: "AM")
                
                let amAttribString = NSAttributedString(string: String(amString), attributes: amPMFontAttributes)
                self.amPMLabel.attributedText = amAttribString
            }
        
        }
    }
    var minutes:Int?{
        didSet{
            if self.minutes != nil
            {
                let mString = self.minutes<10 ? "0"+"\(self.minutes!)" : "\(self.minutes!)"
                let minuteString = NSAttributedString(string: mString, attributes: textFontAttributes)
                self.minuteNumberView.numberString = minuteString
            }
        }
    }
    
    override init(frame: CGRect)
    {
        
        hourNumberView = BGFlipNumberView(frame:CGRect.zero)
        minuteNumberView = BGFlipNumberView(frame:CGRect.zero)
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
        let hourRect = CGRect(x: buffer, y: frame.size.height * 0.5 - squareHeight * 0.5, width: squareHeight, height: squareHeight)
        let minutesRect = CGRect(x: frame.size.width * 0.5 + buffer * 0.5, y: frame.size.height * 0.5 - squareHeight * 0.5, width: squareHeight, height: squareHeight)
        
        self.hourNumberView.frame = hourRect
        self.minuteNumberView.frame = minutesRect
        
        let amSize = "PM".size(attributes: self.amPMFontAttributes)
        let amPMRect = CGRect(x: self.buffer * 2.0, y: self.bounds.size.height * 0.5 + self.squareHeight * 0.5 - amSize.height, width: amSize.width, height: amSize.height)
        self.amPMLabel.frame = amPMRect
        self.amPMLabel.adjustsFontSizeToFitWidth = true
        
        self.hourNumberView.cardColor = self.minuteTickColor
        self.minuteNumberView.cardColor = self.minuteTickColor
        
        self.addSubview(self.minuteNumberView)
        self.addSubview(self.hourNumberView)
        self.addSubview(self.amPMLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        
        hourNumberView = BGFlipNumberView(frame:CGRect.zero)
        minuteNumberView = BGFlipNumberView(frame:CGRect.zero)
        
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
        let hourRect = CGRect(x: self.buffer, y: self.frame.size.height * 0.5 - self.squareHeight * 0.5, width: self.squareHeight, height: self.squareHeight)
        let minutesRect = CGRect(x: self.frame.size.width * 0.5 + self.buffer * 0.5, y: self.frame.size.height * 0.5 - self.squareHeight * 0.5, width: self.squareHeight, height: self.squareHeight)
        
        self.hourNumberView.frame = hourRect
        self.minuteNumberView.frame = minutesRect
        
        let amSize = "PM".size(attributes: amPMFontAttributes)
        let amPMRect = CGRect(x: buffer * 2.0, y: self.bounds.size.height * 0.5 + squareHeight * 0.5 - amSize.height, width: amSize.width, height: amSize.height)
        self.amPMLabel.frame = amPMRect
        self.amPMLabel.adjustsFontSizeToFitWidth = true
        
        self.hourNumberView.cardColor = self.minuteTickColor
        self.minuteNumberView.cardColor = self.minuteTickColor
        
        self.addSubview(self.minuteNumberView)
        self.addSubview(self.hourNumberView)
        self.addSubview(self.amPMLabel)
    }
    
    func updateFrames()
    {
        
        let hourRect = CGRect(x: self.buffer, y: self.frame.size.height * 0.5 - self.squareHeight * 0.5, width: self.squareHeight, height: self.squareHeight)
        let minutesRect = CGRect(x: self.frame.size.width * 0.5 + self.buffer * 0.5, y: self.frame.size.height * 0.5 - self.squareHeight * 0.5, width: self.squareHeight, height: self.squareHeight)
        
        hourNumberView.frame = hourRect
        minuteNumberView.frame = minutesRect
        
        let amSize = "PM".size(attributes: amPMFontAttributes)
        let amPMRect = CGRect(x: buffer * 2.0, y: self.bounds.size.height * 0.5 + squareHeight * 0.5 - amSize.height, width: amSize.width, height: amSize.height)
        self.amPMLabel.frame = amPMRect
    }
    
    func animateMinuteFlipWithMinute(_ newMinute:Int)
    {
        let newNumberView = BGFlipNumberView(frame: self.minuteNumberView.frame)
        newNumberView.cardColor = self.minuteTickColor
        
        let mString = self.minutes<10 ? "0"+"\(newMinute)" : "\(newMinute)"
        let minuteString = NSAttributedString(string: mString, attributes: self.textFontAttributes)
        newNumberView.numberString = minuteString
        self.insertSubview(newNumberView, belowSubview: self.minuteNumberView)
        
        BGFlipTransition.transitionFromView(self.minuteNumberView,toView:newNumberView,dur: 0.3,sty: .backwardVerticalRegularPerspective,act: .none,completion: {(finished:Bool) in
            self.minuteNumberView.removeFromSuperview()
            self.minuteNumberView = newNumberView
            self.minutes = newMinute
            self.minuteAnimating = false
        })
        
    }
    
    func animateHourFlipWithHour(_ newHour:Int)
    {
        let newNumberView = BGFlipNumberView(frame: self.hourNumberView.frame)
        newNumberView.cardColor = self.minuteTickColor
        
        if self.hour != nil
        {
            var hString = self.hour>12 ? "\(self.hour! - 12)" : "\(self.hour!)"
            if self.hour == 0
            {
                hString = "12"
            }
            let hourString = NSAttributedString(string: hString, attributes: self.textFontAttributes)
            self.hourNumberView.numberString = hourString
        }
        self.insertSubview(newNumberView, belowSubview: self.hourNumberView)
        
        BGFlipTransition.transitionFromView(self.hourNumberView,toView:newNumberView,dur: 0.3,sty: .backwardVerticalRegularPerspective,act: .none ,completion: {(finished:Bool) in
            self.hourNumberView.removeFromSuperview()
            self.hourNumberView = newNumberView
            self.hour = newHour
            self.hourAnimating = false
            self.bringSubview(toFront: self.amPMLabel)
        })
        
    }
    
    override func drawFace()
    {
        self.minuteNumberView.cardColor = self.minuteTickColor
        self.hourNumberView.cardColor = self.minuteTickColor
        self.minuteNumberView.setNeedsDisplay()
        self.hourNumberView.setNeedsDisplay()
    }
    
}

private class BGFlipNumberView:UIView {
    var numberString:NSAttributedString?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    var cardColor:UIColor{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var cornerRadius:CGFloat{
        get{
            return self.bounds.size.width * 0.09
        }
    }
    
    override init(frame: CGRect)
    {
        self.cardColor = UIColor.clear
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.cardColor = UIColor.clear
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func draw(_ rect: CGRect)
    {
        self.cardColor.setFill()
        self.cardColor.setStroke()
        
        let numberPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        numberPath.addClip()
        numberPath.stroke()
        numberPath.fill()
        
        if self.numberString != nil
        {
            self.numberString!.draw(in: self.bounds)
        }
        else
        {
            let font = UIFont.systemFont(ofSize: self.bounds.height * 0.80)
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.right
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: UIColor.gray,
                NSParagraphStyleAttributeName: textStyle
            ]
            let tempString = NSAttributedString(string: "00", attributes: textFontAttributes)
            tempString.draw(in: self.bounds)
        }
        
        let context = UIGraphicsGetCurrentContext();

        
        context?.setShadow(offset: CGSize(width: 0, height: 0), blur: self.bounds.size.height * 0.10, color: UIColor(white: 0.0, alpha: 0.80).cgColor)
        
        let flipBreak = UIBezierPath()
        flipBreak.move(to: CGPoint(x: 0.0, y: self.bounds.size.height * 0.5))
        flipBreak.addLine(to: CGPoint(x:  self.bounds.size.width, y: self.bounds.size.height * 0.5))
        UIColor.black.setStroke()
        flipBreak.lineWidth = self.bounds.size.height * 0.02
        flipBreak.stroke()

    }
}

//MARK: - Melting

private class BGMeltingClockFaceView: BGClockFaceView
{
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    override func drawFace()
    {
        self.minuteTickColor.setFill()
        self.minuteTickColor.setStroke()
        
        let lineWidth = self.bounds.size.width * 0.03
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height*0.075))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height*0.345), controlPoint1: CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height * 0.075), controlPoint2: CGPoint(x: self.bounds.size.width * 0.1548, y: self.bounds.size.height*0.2341))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.475), controlPoint1: CGPoint(x: self.bounds.size.width * 0.3352, y: self.bounds.size.height * 0.4559), controlPoint2: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.475))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.585), controlPoint1: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height * 0.475), controlPoint2: CGPoint(x: self.bounds.size.width * 0.3665, y: self.bounds.size.height*0.5678))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535), controlPoint1: CGPoint(x: self.bounds.size.width * 0.4235, y: self.bounds.size.height * 0.6022), controlPoint2: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.515, y: self.bounds.size.height*0.615), controlPoint1: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height * 0.535), controlPoint2: CGPoint(x: self.bounds.size.width * 0.5007, y: self.bounds.size.height*0.4945))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height*0.765), controlPoint1: CGPoint(x: self.bounds.size.width * 0.5293, y: self.bounds.size.height * 0.7355), controlPoint2: CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height*0.765))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.605, y: self.bounds.size.height*0.815), controlPoint1: CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height * 0.765), controlPoint2: CGPoint(x: self.bounds.size.width * 0.5986, y: self.bounds.size.height*0.7844))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965), controlPoint1: CGPoint(x: self.bounds.size.width * 0.6317, y: self.bounds.size.height * 0.9289), controlPoint2: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.715, y: self.bounds.size.height*0.905), controlPoint1: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height * 0.965), controlPoint2: CGPoint(x: self.bounds.size.width * 0.6804, y: self.bounds.size.height*1.045))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.785, y: self.bounds.size.height*0.725), controlPoint1: CGPoint(x: self.bounds.size.width * 0.7496, y: self.bounds.size.height * 0.765), controlPoint2: CGPoint(x: self.bounds.size.width * 0.785, y: self.bounds.size.height*0.725))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.865, y: self.bounds.size.height*0.405), controlPoint1: CGPoint(x: self.bounds.size.width * 0.785, y: self.bounds.size.height * 0.725), controlPoint2: CGPoint(x: self.bounds.size.width * 0.8899, y: self.bounds.size.height*0.5201))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.755, y: self.bounds.size.height*0.265), controlPoint1: CGPoint(x: self.bounds.size.width * 0.8401, y: self.bounds.size.height * 0.2899), controlPoint2: CGPoint(x: self.bounds.size.width * 0.755, y: self.bounds.size.height*0.265))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height*0.115), controlPoint1: CGPoint(x: self.bounds.size.width * 0.755, y: self.bounds.size.height * 0.265), controlPoint2: CGPoint(x: self.bounds.size.width * 0.595, y: self.bounds.size.height*0.1971))
        
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.355, y: self.bounds.size.height*0.015), controlPoint1: CGPoint(x: self.bounds.size.width * 0.515, y: self.bounds.size.height * 0.0329), controlPoint2: CGPoint(x: self.bounds.size.width * 0.355, y: self.bounds.size.height*0.015))
        path.addCurve(to: CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height*0.075), controlPoint1: CGPoint(x: self.bounds.size.width * 0.355, y: self.bounds.size.height * 0.015), controlPoint2: CGPoint(x: self.bounds.size.width * 0.2837, y: self.bounds.size.height*0.008))
        
        let path2 = UIBezierPath();
        path2.move(to: CGPoint(x: self.bounds.size.width * 0.41, y: self.bounds.size.height*0.47))
        path2.addCurve(to: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.585), controlPoint1: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height * 0.475), controlPoint2: CGPoint(x: self.bounds.size.width * 0.3665, y: self.bounds.size.height*0.5678))
        path2.addCurve(to: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535), controlPoint1: CGPoint(x: self.bounds.size.width * 0.4235, y: self.bounds.size.height * 0.6022), controlPoint2: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535))
        path2.addQuadCurve(to: CGPoint(x: self.bounds.size.width * 0.41, y: self.bounds.size.height*0.47), controlPoint: CGPoint(x: self.bounds.size.width * 0.40, y: self.bounds.size.height*0.56))
        path2.stroke()
        path2.fill()
        
        let path3 = UIBezierPath();
        path3.move(to: CGPoint(x: self.bounds.size.width * 0.605, y: self.bounds.size.height*0.815))
        path3.addCurve(to: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965), controlPoint1: CGPoint(x: self.bounds.size.width * 0.6317, y: self.bounds.size.height * 0.9289), controlPoint2: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965))
        path3.addCurve(to: CGPoint(x: self.bounds.size.width * 0.715, y: self.bounds.size.height*0.905), controlPoint1: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height * 0.965), controlPoint2: CGPoint(x: self.bounds.size.width * 0.6804, y: self.bounds.size.height*1.045))
        path3.addLine(to: CGPoint(x: self.bounds.size.width * 0.73, y: self.bounds.size.height*0.815))
        path3.addQuadCurve(to: CGPoint(x: self.bounds.size.width * 0.605, y: self.bounds.size.height*0.815), controlPoint: CGPoint(x: self.bounds.size.width * 0.665, y: self.bounds.size.height*0.90))
        path3.stroke()
        path3.fill()
        
        path.lineWidth = lineWidth
        path.stroke()
        
        let context = UIGraphicsGetCurrentContext();
        context?.saveGState();
        context?.rotate(by: self.degreesToRadians(-10.0))
        
        var font = self.faceFont!.withSize(self.bounds.size.height * 0.08)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center
        var textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ] as [String : Any]
        
        let string12 = NSAttributedString(string: "12", attributes: textFontAttributes)
        string12.draw(at: CGPoint(x: self.bounds.size.width * 0.20, y: self.bounds.size.height*0.17))
        
        let string11 = NSAttributedString(string: "11", attributes: textFontAttributes)
        string11.draw(at: CGPoint(x: self.bounds.size.width * 0.19, y: self.bounds.size.height*0.26))
        
        let string10 = NSAttributedString(string: "10", attributes: textFontAttributes)
        string10.draw(at: CGPoint(x: self.bounds.size.width * 0.23, y: self.bounds.size.height*0.34))
        
        font = self.faceFont!.withSize(self.bounds.size.height * 0.12)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string9 = NSAttributedString(string: "9", attributes: textFontAttributes)
        string9.draw(at: CGPoint(x: self.bounds.size.width * 0.32, y: self.bounds.size.height*0.43))
        
        let string8 = NSAttributedString(string: "8", attributes: textFontAttributes)
        string8.draw(at: CGPoint(x: self.bounds.size.width * 0.40, y: self.bounds.size.height*0.51))
        
        font = self.faceFont!.withSize(self.bounds.size.height * 0.16)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string7 = NSAttributedString(string: "7", attributes: textFontAttributes)
        string7.draw(at: CGPoint(x: self.bounds.size.width * 0.42, y: self.bounds.size.height*0.64))
        
        let string6 = NSAttributedString(string: "6", attributes: textFontAttributes)
        string6.draw(at: CGPoint(x: self.bounds.size.width * 0.48, y: self.bounds.size.height*0.79))
        
        font = self.faceFont!.withSize(self.bounds.size.height * 0.20)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        context?.restoreGState();
        context?.saveGState();
        
        context?.rotate(by: self.degreesToRadians(10.0))
        
        
        let string5 = NSAttributedString(string: "5", attributes: textFontAttributes)
        string5.draw(at: CGPoint(x: self.bounds.size.width * 0.79, y: self.bounds.size.height*0.35))
        
        context?.restoreGState();
        context?.saveGState();
        
        context?.rotate(by: self.degreesToRadians(-10.0))
        
        let string4 = NSAttributedString(string: "4", attributes: textFontAttributes)
        string4.draw(at: CGPoint(x: self.bounds.size.width * 0.62, y: self.bounds.size.height*0.38))
        
        font = self.faceFont!.withSize(self.bounds.size.height * 0.18)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        context?.restoreGState();
        context?.saveGState();
        
        context?.rotate(by: self.degreesToRadians(-30.0))
        
        let string3 = NSAttributedString(string: "3", attributes: textFontAttributes)
        string3.draw(at: CGPoint(x: self.bounds.size.width * 0.33, y: self.bounds.size.height*0.43))
        
        font = self.faceFont!.withSize(self.bounds.size.height * 0.12)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string2 = NSAttributedString(string: "2", attributes: textFontAttributes)
        string2.draw(at: CGPoint(x: self.bounds.size.width * 0.30, y: self.bounds.size.height*0.30))
        
        let string1 = NSAttributedString(string: "1", attributes: textFontAttributes)
        string1.draw(at: CGPoint(x: self.bounds.size.width * 0.22, y: self.bounds.size.height*0.18))
        
        context?.restoreGState();
        
    }
}

private class BGMeltingClockMinuteHandView: BGMeltingClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.035,color:self.handColor)
    }
}

private class BGMeltingClockHourHandView: BGMeltingClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.035,color: self.handColor)
    }
}

private class BGMeltingClockSecondHandView: BGAppleWatchClockSecondHandView {
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        self.drawHandWithPercentLength(0.60, percentWidth: 0.01,color:self.handColor)
        
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalIn: screwRect)
        self.handColor.setStroke()
        self.handColor.setFill()
        
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalIn: screwRect.insetBy(dx: screwRadius*0.5, dy: screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
    }
}

private class BGMeltingClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let handLength = self.bounds.size.height * percentLength
        let lineWidth = self.bounds.size.width*percentWidth;
        
        color.setFill()
        color.setStroke()
        
        let path = UIBezierPath()
        path.lineCapStyle = .round
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalIn:centerScrewRect)
        path.append(screwCircle)
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: self.bounds.size.width * 0.5 - lineWidth * 0.25, y: self.bounds.size.height * 0.5))
        line.addLine(to: CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5 - handLength));
        line.addLine(to: CGPoint(x: self.bounds.size.width * 0.5 + lineWidth * 0.25, y: self.bounds.size.height * 0.5))
        line.stroke()
        line.fill()
        
        let line2 = UIBezierPath()
        line2.move(to: CGPoint(x:self.bounds.size.width * 0.5 - lineWidth * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75))
        line2.addQuadCurve(to: CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75 + lineWidth * 0.5), controlPoint: CGPoint (x: self.bounds.size.width * 0.5 - lineWidth * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75 + lineWidth * 0.5))
        line2.addQuadCurve(to: CGPoint(x: self.bounds.size.width * 0.5 + lineWidth * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75), controlPoint: CGPoint (x: self.bounds.size.width * 0.5 + lineWidth * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75 + lineWidth * 0.5))
        line2.addQuadCurve(to: CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5 - handLength), controlPoint: CGPoint(x:self.bounds.size.width * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75))
        line2.addQuadCurve(to: CGPoint(x:self.bounds.size.width * 0.5 - lineWidth * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75), controlPoint: CGPoint(x:self.bounds.size.width * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75))
        path.append(line2)
        
        path.stroke()
        path.fill()
        
    }
    
    func degreesToRadians(_ degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat.pi / 180.0
    }
}


//MARK: - Swiss/Base Class

private class BGClockSecondHandView: BGClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.40, percentWidth: 0.01,color:self.handColor)
        
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalIn: screwRect)
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalIn: screwRect.insetBy(dx: screwRadius*0.5, dy: screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
        
    }
    
    override func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        color.setFill()
        color.setStroke()
        
        context?.saveGState();
        
        
        let handLength = self.bounds.size.height * percentLength
        let path = UIBezierPath()
        let startingY = self.bounds.size.height * 0.6 - handLength
        path .move(to: CGPoint(x: self.bounds.size.width*0.5, y: startingY))
        path.addLine(to: CGPoint(x: self.bounds.size.width*0.5, y: startingY + handLength))
        path.lineWidth = self.bounds.size.width * percentWidth;
        color.setStroke()
        
        let radius:CGFloat = self.bounds.size.width * 0.045
        
        let circle = UIBezierPath(ovalIn: CGRect(x: self.bounds.size.width*0.5 - radius, y: startingY - radius, width: radius * 2.0, height: radius * 2.0))
        
        
        path.append(circle)
        
        
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let pathCopy = path.copy();
        let cgPathShadowPath = CGPath(__byStroking: (pathCopy as AnyObject).cgPath, transform: nil, lineWidth: (pathCopy as AnyObject).lineWidth, lineCap: (pathCopy as AnyObject).lineCapStyle, lineJoin: (pathCopy as AnyObject).lineJoinStyle, miterLimit: (pathCopy as AnyObject).miterLimit);
        
        let shadowPath = UIBezierPath(cgPath: cgPathShadowPath!)
        
        shadowPath.stroke()
        shadowPath.fill()
        
        context?.restoreGState();
        
        path.stroke()
        path.fill()
    }
}

private class BGClockMinuteHandView: BGClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.50, percentWidth: 0.045,color:self.handColor)
    }
}

private class BGClockHourHandView: BGClockHandView
{
    override func draw(_ rect: CGRect)
    {
        self.drawHandWithPercentLength(0.40, percentWidth: 0.06,color: self.handColor)
    }
}

private class BGClockHandView: UIView
{
    var handColor:UIColor
    var secondHandScrewColor:UIColor
    var hasDropShadow:Bool
    
    override init(frame: CGRect)
    {
        self.secondHandScrewColor = UIColor.white
        self.handColor = UIColor.black
        self.hasDropShadow = false
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.secondHandScrewColor = UIColor.white
        self.handColor = UIColor.black
        self.hasDropShadow = false

        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        
        
    }
    
    func drawHandWithPercentLength(_ percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            context?.setShadow(offset: CGSize(width: 0, height: self.bounds.size.height * 0.015), blur: self.bounds.size.height * 0.015, color: UIColor(white: 0.0, alpha: 0.30).cgColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        let path = UIBezierPath()
        let startingY = self.bounds.size.height * 0.6 - handLength
        path .move(to: CGPoint(x: self.bounds.size.width*0.5, y: startingY))
        path.addLine(to: CGPoint(x: self.bounds.size.width*0.5, y: startingY + handLength))
        path.lineWidth = self.bounds.size.width * percentWidth;
        color.setStroke()
        path.stroke()
    }
}

private class BGClockFaceView: UIView
{
    var minuteTickColor:UIColor
    var secondTickColor:UIColor
    var textColor:UIColor
    var faceFont:UIFont?
    
    override init(frame: CGRect)
    {
        self.minuteTickColor = UIColor.black
        self.secondTickColor = UIColor.black
        self.textColor = UIColor.black
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.minuteTickColor = UIColor.black
        self.secondTickColor = UIColor.black
        self.textColor = UIColor.black
        
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        self.contentMode = .redraw
        self.isOpaque = false
    }
    
    func drawFace()
    {
        self.drawMinuteTicksWithColor(minuteTickColor)
        self.drawSecondTicksWithColor(secondTickColor)
    }
    
    func drawMinuteTicksWithColor(_ color:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            context?.translateBy(x: translateX, y: translateY)
            context?.rotate(by: self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: 0.0))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -0.125))
            path.lineWidth = self.bounds.size.width * 0.04;
            color.setStroke()
            path.stroke()
            context?.restoreGState();
        }
    }
    
    func drawSecondTicksWithColor(_ color:UIColor)
    {
        for i in 0...59{
            let context = UIGraphicsGetCurrentContext();
            context?.saveGState();
            let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            
            context?.translateBy(x: translateX, y: translateY)
            context?.rotate(by: self.degreesToRadians(-360.0/60.0*CGFloat(i)))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0,y: 0.0))
            path.addLine(to: CGPoint(x: 0.0,y: self.bounds.size.width * -0.03))
            path.lineWidth = self.bounds.size.width * 0.0075;
            color.setStroke()
            path.stroke()
            context?.restoreGState();
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        self.drawFace()
    }
    
    func degreesToRadians(_ degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat.pi / 180.0
    }
}
