//
//  BGClockView.swift
//  Clock
//
//  Created by Brad G. on 2/25/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit

enum FaceStyle
{
    case Swiss
    case Normal
    case Simple
    case Utility
    case BigBen
    case Melting
    case Minimal
    case Plain
    case Square
    case Chrono
    case Flip
    case Zulu
}

enum HandStyle
{
    case Swiss
    case AppleWatch
    case Chrono
    case BigBen
    case Melting
    case Minimal
    case Plain
}

//MARK: - Clock View

class BGClockView: UIView {
    private var clockFace:BGClockFaceView =      BGClockFaceView()
    private var hourHand:BGClockHandView =       BGClockHourHandView()
    private var minHand:BGClockHandView =        BGClockMinuteHandView()
    private var secHand:BGClockHandView =        BGClockSecondHandView()
    private var chronosSecondHandTop:            UIView?
    private var chronosSecondHandBottom:         UIView?
    private var dateLabel:                       UILabel?
    
    /**
     * The time zone name for the time displayed on the clock, for example `America/New_York`. A complete list is available by calling `NSTimeZone.knownTimeZoneNames()`
     */
    var timeZoneNameString:                      String?
    private var displayLink:                     CADisplayLink?
    
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
            self.dateLabel?.hidden = self.hideDateLabel
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
    
    private var secondHandImageView:UIImageView?
    
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
                self.secondHandImageView?.contentMode = .ScaleAspectFit
                self.insertSubview(self.secondHandImageView!, belowSubview: self.secHand)
                self.secHand.removeFromSuperview()
            }
        }
    }
    
    private var minuteHandImageView:UIImageView?
    
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
                self.minuteHandImageView?.contentMode = .ScaleAspectFit
                self.insertSubview(self.minuteHandImageView!, belowSubview: self.minHand)
                self.minHand.removeFromSuperview()
            }
        }
    }
    
    private var hourHandImageView:UIImageView?
    
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
                self.hourHandImageView?.contentMode = .ScaleAspectFit
                self.insertSubview(self.hourHandImageView!, belowSubview: self.hourHand)
                self.hourHand.removeFromSuperview()
            }
        }
    }
    
    private var clockFaceImageView:UIImageView?
    
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
                self.clockFaceImageView?.contentMode = .ScaleAspectFit
                self.insertSubview(self.clockFaceImageView!, belowSubview: self.clockFace)
                self.clockFace.removeFromSuperview()
            }
        }
    }
    
    override init(frame: CGRect)
    {
        
        self.minuteTickColor = UIColor.blackColor()
        self.secondTickColor = UIColor.blackColor()
        self.textColor =       UIColor.blackColor()
        self.minuteHandColor = UIColor.blackColor()
        self.hourHandColor =   UIColor.blackColor()
        self.secondHandColor = UIColor.redColor()
        self.screwColor =      UIColor.whiteColor()
        self.faceFont =        UIFont.systemFontOfSize(12.0)
        
        self.face = .Swiss
        self.hand = .Swiss
        
        super.init(frame: frame)
        defaultSetup()
        self.contentMode = .Redraw
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        
        self.minuteTickColor = UIColor.blackColor()
        self.secondTickColor = UIColor.blackColor()
        self.textColor = UIColor.blackColor()
        self.minuteHandColor = UIColor.blackColor()
        self.hourHandColor = UIColor.blackColor()
        self.secondHandColor = UIColor.redColor()
        self.screwColor =      UIColor.whiteColor()
        self.faceFont =        UIFont.systemFontOfSize(12.0)
        
        self.face = .Swiss
        self.hand = .Swiss
        
        super.init(coder: aDecoder)
        defaultSetup()
        self.contentMode = .Redraw
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override var bounds: CGRect {
        didSet {
            for view in self.subviews{
                view.removeFromSuperview()
            }
            self.defaultSetup()
        }
    }
    
    private func updateUI()
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
    
    private func defaultSetup()
    {
        
        self.setupFace()
        self.setupHands()
        
        self.updateUI()
        
        if self.face != .Square {
            if self.bounds.size.width < self.bounds.size.height
            {
                self.clockFace.frame = CGRectMake(0.0, (self.bounds.size.height-self.bounds.size.width)*0.5, self.bounds.size.width, self.bounds.size.width)
            }else{
                self.clockFace.frame = CGRectMake((self.bounds.size.width-self.bounds.size.height)*0.5,0.0 , self.bounds.size.height, self.bounds.size.height)
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
                handRect = CGRectMake(0.0, (self.bounds.size.height-self.bounds.size.width)*0.5, self.bounds.size.width, self.bounds.size.width)
            }else{
                handRect = CGRectMake((self.bounds.size.width-self.bounds.size.height)*0.5,0.0 , self.bounds.size.height, self.bounds.size.height)
            }
            self.hourHand.frame = handRect
            self.minHand.frame = handRect
            self.secHand.frame = handRect
        }
        
        
        
        if self.face == .Melting
        {
            self.hourHand.frame.size = CGSize(width:self.clockFace.bounds.size.width * 0.5,height:self.clockFace.bounds.size.height * 0.5)
            self.minHand.frame.size = CGSize(width:self.clockFace.bounds.size.width * 0.5,height:self.clockFace.bounds.size.height * 0.5)
            self.secHand.frame.size = CGSize(width:self.clockFace.bounds.size.width * 0.5,height:self.clockFace.bounds.size.height * 0.5)
            
            self.hourHand.center = CGPoint(x: self.clockFace.center.x + self.clockFace.bounds.size.width * 0.08, y: self.clockFace.center.y - self.clockFace.bounds.size.height * 0.10)
            self.minHand.center = CGPoint(x: self.clockFace.center.x + self.clockFace.bounds.size.width * 0.08, y: self.clockFace.center.y - self.clockFace.bounds.size.height * 0.10)
            self.secHand.center = CGPoint(x: self.clockFace.center.x + self.clockFace.bounds.size.width * 0.08, y: self.clockFace.center.y - self.clockFace.bounds.size.height * 0.10)
        }
        
        self.addSubview(self.clockFace)
        
        if self.face != .Flip
        {
            self.addSubview(self.hourHand)
            self.addSubview(self.minHand)
        }
        
        if self.hand != .BigBen && self.face != .Flip
        {
            self.addSubview(self.secHand)
        }
        
        if self.face != .BigBen && self.face != .Melting && self.face != .Flip
        {
            if self.face != .Simple && self.face != .Swiss && self.face != .Chrono
            {
                self.dateLabel = UILabel(frame: CGRect(x: self.clockFace.bounds.size.width*0.725-self.clockFace.bounds.size.width*0.07, y: self.clockFace.bounds.size.height*0.5-self.clockFace.bounds.size.height*0.07, width: self.clockFace.bounds.size.width*0.14, height: self.clockFace.bounds.size.height*0.14))
            }
            else if self.face == .Chrono
            {
                self.dateLabel = UILabel(frame: CGRect(x: self.clockFace.bounds.size.width*0.70-self.clockFace.bounds.size.width*0.11, y: self.clockFace.bounds.size.height*0.5-self.clockFace.bounds.size.height*0.08, width: self.clockFace.bounds.size.width*0.24, height: self.clockFace.bounds.size.height*0.14))
            }
            else
            {
                self.dateLabel = UILabel(frame: CGRect(x: self.clockFace.bounds.size.width*0.70-self.clockFace.bounds.size.width*0.07, y: self.clockFace.bounds.size.height*0.5-self.clockFace.bounds.size.height*0.07, width: self.clockFace.bounds.size.width*0.14, height: self.clockFace.bounds.size.height*0.14))
            }
            
            self.dateLabel?.hidden = self.hideDateLabel
            self.dateLabel?.textAlignment = .Center
            self.dateLabel?.textColor = self.textColor
            self.dateLabel?.font = self.faceFont.fontWithSize(self.clockFace.bounds.size.height*0.08)
            self.dateLabel?.minimumScaleFactor = 0.5
            self.dateLabel?.adjustsFontSizeToFitWidth = true
            self.clockFace.addSubview(self.dateLabel!)
        }
    }
    
    private func setupFace()
    {
        switch self.face {
        case .Swiss:
            self.clockFace = BGClockFaceView()
            break
        case .Normal:
            self.clockFace = BGNormalClockFaceView()
            break
        case .Simple    :
            self.clockFace = BGSimpleClockFaceView()
            break
        case .Minimal    :
            self.clockFace = BGMinimalClockFaceView()
            break
        case .Utility    :
            self.clockFace = BGUtilityClockFaceView()
            break
        case .BigBen    :
            self.clockFace = BGBigBenClockFaceView()
            break
        case .Melting    :
            self.clockFace = BGMeltingClockFaceView()
            break
        case .Plain    :
            self.clockFace = BGPlainClockFaceView()
            break
        case .Square    :
            self.clockFace = BGSquareClockFaceView()
            break
        case .Chrono    :
            self.clockFace = BGChronoClockFaceView()
            break
        case .Flip    :
            self.clockFace = BGFlipClockFaceView()
            break
        case .Zulu    :
            self.clockFace = BG24HourClockFaceView()
            break
        }
    }
    
    private func setupHands()
    {
        switch self.hand {
        case .Swiss:
            self.hourHand = BGClockHourHandView()
            self.minHand = BGClockMinuteHandView()
            self.secHand = BGClockSecondHandView()
            break
        case .AppleWatch:
            self.hourHand = BGAppleWatchClockHourHandView()
            self.minHand = BGAppleWatchClockMinuteHandView()
            self.secHand = BGAppleWatchClockSecondHandView()
            break
        case .BigBen:
            self.hourHand = BGBigBenClockHourHandView()
            self.minHand = BGBigBenClockMinuteHandView()
            break
        case .Melting:
            self.hourHand = BGMeltingClockHourHandView()
            self.minHand = BGMeltingClockMinuteHandView()
            self.secHand = BGMeltingClockSecondHandView()
            break
        case .Minimal:
            self.hourHand = BGMinimalClockHourHandView()
            self.minHand = BGMinimalClockMinuteHandView()
            self.secHand = BGMinimalClockSecondHandView()
            break
        case .Chrono:
            self.hourHand = BGAppleWatchChronoClockHourHandView()
            self.minHand = BGAppleWatchChronoClockMinuteHandView()
            self.secHand = BGAppleWatchClockSecondHandView()
            break
        case .Plain:
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
        self.displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    /**
     * Stop animating the clock
     */
    func stop()
    {
        self.displayLink?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    /**
     * Set the clock to a specified time
     * Parameter: day is the day of the month
     * Parameter: hours is the hour of the day with 0 being midnight and 23 being 11 pm
     * Parameter: minute is the minute of the hour
     * Parameter: second is the seconds of the minute
     * Parameter: weekday is the day of the week 1 being Sunday and 7 being Saturday (only used with .Chrono face)
     */
    func setClockToTime(day:Int,hours:Int,minute:Int,second:Int,weekday:Int)
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
        
        if self.face == .Melting && self.face != .Flip
        {
            let secScaleTransform = CGAffineTransformMakeScale(1.0, abs(cos(secAngle)) * 0.25 + 0.75)
            let minScaleTransform = CGAffineTransformMakeScale(1.0, abs(cos(minAngle)) * 0.25 + 0.75)
            let hourScaleTransform = CGAffineTransformMakeScale(1.0, abs(cos(hourAngle)) * 0.25 + 0.75)
            
            secAngle  += degreesToRadians(-55.0)
            minAngle  += degreesToRadians(-55.0)
            hourAngle += degreesToRadians(-55.0)
            
            self.secHand.transform = CGAffineTransformConcat(secScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, secAngle))
            self.minHand.transform = CGAffineTransformConcat(minScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, minAngle))
            self.hourHand.transform = CGAffineTransformConcat(hourScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle))
            self.secondHandImageView?.transform = CGAffineTransformConcat(secScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, secAngle))
            self.minuteHandImageView?.transform = CGAffineTransformConcat(minScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, minAngle))
            self.hourHandImageView?.transform = CGAffineTransformConcat(hourScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle))
        }
        else if self.face != .Flip
        {
            self.secHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, secAngle)
            self.minHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, minAngle)
            self.hourHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle)
            self.secondHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, secAngle)
            self.minuteHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, minAngle)
            self.hourHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle)
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
        
        if self.face == .Chrono
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
        var dateComponents:NSDateComponents
        if self.timeZoneNameString == nil
        {
            dateComponents = NSCalendar.currentCalendar().components([.Day,.Hour,.Minute,.Second,.Nanosecond,.Weekday], fromDate: NSDate())
        }
        else
        {
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            calendar?.timeZone = NSTimeZone(name: self.timeZoneNameString!)!
            dateComponents = calendar!.components([.Day,.Hour,.Minute,.Second,.Nanosecond,.Weekday], fromDate: NSDate())
        }
        let seconds     = dateComponents.second
        let minutes     = dateComponents.minute
        let hours       = dateComponents.hour
        let day         = dateComponents.day
        let nanoSeconds = dateComponents.nanosecond
        let weekday     = dateComponents.weekday
        
        let nanoSecondsFloat = CGFloat(nanoSeconds)/1000000000.0
        let secondsFloat     = CGFloat(seconds) + nanoSecondsFloat
        let minutesFloat     = CGFloat(minutes) + secondsFloat/60.0
        let twelveHoursHour:Int
        if hours > 12
        {
            twelveHoursHour = hours - 12
        }
        else
        {
            twelveHoursHour = hours
        }
        
        let hoursFloat = CGFloat(twelveHoursHour) + minutesFloat/60.0
        let twentyFourHoursFloat = CGFloat(hours) + minutesFloat/60.0
        
        var secAngle: CGFloat
        
        if self.continuous
        {
            secAngle  = degreesToRadians(secondsFloat/60.0 * 360.0)
        }
        else
        {
            secAngle = degreesToRadians(CGFloat(seconds)/60.0 * 360.0)
        }
        
        var minAngle  = degreesToRadians(minutesFloat/60.0 * 360.0)
        var hourAngle = degreesToRadians(hoursFloat/12.0 * 360.0)
        let twentyFourHoursAngle = degreesToRadians(twentyFourHoursFloat/24.0 * 360.0)
        
        if self.face == .Melting
        {
            let secScaleTransform = CGAffineTransformMakeScale(1.0, abs(cos(secAngle)) * 0.25 + 0.75)
            let minScaleTransform = CGAffineTransformMakeScale(1.0, abs(cos(minAngle)) * 0.25 + 0.75)
            let hourScaleTransform = CGAffineTransformMakeScale(1.0, abs(cos(hourAngle)) * 0.25 + 0.75)
            
            secAngle  += degreesToRadians(-55.0)
            minAngle  += degreesToRadians(-55.0)
            hourAngle += degreesToRadians(-55.0)
            
            self.secHand.transform = CGAffineTransformConcat(secScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, secAngle))
            self.minHand.transform = CGAffineTransformConcat(minScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, minAngle))
            self.hourHand.transform = CGAffineTransformConcat(hourScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle))
            self.secondHandImageView?.transform = CGAffineTransformConcat(secScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, secAngle))
            self.minuteHandImageView?.transform = CGAffineTransformConcat(minScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, minAngle))
            self.hourHandImageView?.transform = CGAffineTransformConcat(hourScaleTransform, CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle))
        }
        else if self.face != .Flip
        {
            self.secHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, secAngle)
            self.minHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, minAngle)
            self.hourHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle)
            self.secondHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, secAngle)
            self.minuteHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, minAngle)
            self.hourHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, hourAngle)
            if self.face == .Zulu
            {
                self.hourHand.transform = CGAffineTransformRotate(CGAffineTransformIdentity, twentyFourHoursAngle)
                self.hourHandImageView?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, twentyFourHoursAngle)
            }
        }
        else
        {
            let flipClockFace = self.clockFace as! BGFlipClockFaceView
            if (flipClockFace.hour != hours || flipClockFace.hour == nil) && !flipClockFace.hourAnimating
            {
                flipClockFace.hourAnimating = true
                flipClockFace.animateHourFlipWithHour(hours)
            }
            if (flipClockFace.minutes != minutes || flipClockFace.minutes == nil) && !flipClockFace.minuteAnimating
            {
                flipClockFace.minuteAnimating = true
                flipClockFace.animateMinuteFlipWithMinute(minutes)
            }
        }
        if self.face == .Chrono
        {
            self.dateLabel?.text = weekdayStringForWeekday(weekday) + " \(day)"
        }
        else
        {
            self.dateLabel?.text = String(stringInterpolationSegment: day)
        }
    }
    
    private func weekdayStringForWeekday(weekday:Int) -> String
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
    
    private func degreesToRadians(degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat(M_PI) / 180.0
    }
    
}

//MARK: - Apple Watch
private class BGSimpleClockFaceView: BGClockFaceView
{
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawFace()
    {
        
        self.drawSecondTicksWithPercentLength(0.025, percentWidth: 0.005,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.045, percentWidth: 0.01,percentFontSize:0.05,tickColor: minuteTickColor,fontColor: textColor)
    }
    
    func drawMinuteTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            let font = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let verticalBuffer = self.bounds.size.height*0.01
            let horizontalBuffer = self.bounds.size.width*0.025
            
            if 360.0/12.0*CGFloat(index) % 30.0 == 0
            {
                switch (360.0/12.0*CGFloat(index))/30.0{
                case 1.0:
                    let numberString:NSString = "25"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: 0.0, y: 1.0*(percentLength*self.bounds.size.height+verticalBuffer)-numberSize.height)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 2.0:
                    let numberString:NSString = "20"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: 0.0, y: 1.0*(percentLength*self.bounds.size.height+verticalBuffer)-numberSize.height)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 4.0:
                    let numberString:NSString = "10"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: 0.0, y: -numberSize.height+verticalBuffer)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 5.0:
                    let numberString:NSString = "05"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: 0.0, y: -numberSize.height+verticalBuffer)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 7.0:
                    let numberString:NSString = "55"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+horizontalBuffer, y: -numberSize.height)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 8.0:
                    let numberString:NSString = "50"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+verticalBuffer, y: -numberSize.height)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 10.0:
                    let numberString:NSString = "40"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+verticalBuffer, y: -verticalBuffer)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 11.0:
                    let numberString:NSString = "35"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: -numberSize.width+verticalBuffer, y: -verticalBuffer)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawInRect(rect, withAttributes: textFontAttributes)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                    
                default:
                    break
                }
            }
            
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: -verticalBuffer))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength-verticalBuffer))
            path.lineWidth = self.bounds.size.width * percentWidth;
            
            tickColor.setStroke()
            tickColor.setFill()
            
            path.stroke()
            
            let roundRectRect = CGRect(x: -self.bounds.size.width * percentWidth*1.25, y: (self.bounds.size.width * -percentLength)-(verticalBuffer*4.0)-(self.bounds.size.width * percentLength*3.0), width: self.bounds.size.width * percentWidth*2.5, height: self.bounds.size.width * percentLength*3.0)
            let roundRect = UIBezierPath(roundedRect: roundRectRect, cornerRadius: self.bounds.size.width * percentWidth*1.25)
            roundRect.stroke()
            roundRect.fill()
            
            CGContextRestoreGState(context);
        }
    }
    
    func drawSecondTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let verticalBuffer = self.bounds.size.height*0.01
        
        for i in 0...119{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/120.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/120.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            
            CGContextTranslateCTM(context, translateX, translateY)
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/120.0*CGFloat(i)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: -verticalBuffer))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength-verticalBuffer))
            path.lineWidth = self.bounds.size.width * percentWidth;
            color.setStroke()
            path.stroke()
            CGContextRestoreGState(context);
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        self.drawFace()
    }
}

private class BGNormalClockFaceView: BGClockFaceView
{
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawFace()
    {
        
        self.drawSecondTicksWithPercentLength(0.05, percentWidth: 0.005,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.05, percentWidth: 0.015,percentFontSize:0.15,tickColor: minuteTickColor,fontColor: textColor)
    }
    
    func drawMinuteTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            let font = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let verticalBuffer = self.bounds.size.height*0.01
            let horizontalBuffer = self.bounds.size.width*0.025
            
            if 360.0/12.0*CGFloat(index) % 90.0 == 0
            {
                switch (360.0/12.0*CGFloat(index))/90.0{
                case 0.0:
                    let numberString:NSString = "6"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: 0.0-numberSize.width*0.5, y: -1.0*(percentLength*self.bounds.size.height+verticalBuffer)-numberSize.height)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 1.0:
                    let numberString:NSString = "3"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x:-1.0*(percentLength*self.bounds.size.width+horizontalBuffer)-numberSize.width , y:-numberSize.height*0.5 )
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 2.0:
                    let numberString:NSString = "12"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x: 0.0-numberSize.width*0.5, y: percentLength*self.bounds.size.height+verticalBuffer)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 3.0:
                    let numberString:NSString = "9"
                    let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                    let point = CGPoint(x:1.0*(percentLength*self.bounds.size.width+horizontalBuffer), y:0.0-numberSize.height*0.5)
                    var rect = CGRectZero
                    rect.origin = point
                    rect.size = numberSize
                    
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                default:
                    break
                }
            }
            
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
            path.lineWidth = self.bounds.size.width * percentWidth;
            tickColor.setStroke()
            path.stroke()
            CGContextRestoreGState(context);
        }
    }
    
    func drawSecondTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        for i in 0...59{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            
            CGContextTranslateCTM(context, translateX, translateY)
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(i)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
            path.lineWidth = self.bounds.size.width * percentWidth;
            color.setStroke()
            path.stroke()
            CGContextRestoreGState(context);
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        self.drawFace()
    }
}


private class BGUtilityClockFaceView: BGClockFaceView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawFace()
    {
        
        self.drawSecondTicksWithPercentLength(0.04, percentWidth: 0.004,color: secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.0, percentWidth: 0.00,percentFontSize:0.041,tickColor: minuteTickColor,fontColor: self.textColor)
    }
    
    func drawMinuteTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        self.drawLargeNumbers(percentFontSize, fontColor: fontColor,percentInset: 0.13)
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            
            let angle = 360.0/12.0*CGFloat(index)

            let translateX = sin(self.degreesToRadians(angle))*self.frame.size.width*0.48+self.frame.size.width*0.505
            let translateY = cos(degreesToRadians(angle))*self.frame.size.width*0.48+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            let font = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: minuteTickColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            let numberSize = "     ".sizeWithAttributes(textFontAttributes)

            if angle % 30.0 == 0
            {
                switch angle/30.0{
                case 0.0:
                    let numberString:NSString = "30"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 1.0:
                    let numberString:NSString = "25"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 2.0:
                    let numberString:NSString = "20"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                case 3.0:
                    let numberString:NSString = "15"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 4.0:
                    let numberString:NSString = "10"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 5.0:
                    let numberString:NSString = "05"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 6.0:
                    let numberString:NSString = "60"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 7.0:
                    let numberString:NSString = "55"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 8.0:
                    let numberString:NSString = "50"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 9.0:
                    let numberString:NSString = "45"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 10.0:
                    let numberString:NSString = "40"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                case 11.0:
                    let numberString:NSString = "35"
                    let point = CGPoint(x: -numberSize.width * 0.5, y: -numberSize.height * 0.5)
                    numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                    break
                default:
                    break
                }
            }
            
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            CGContextRestoreGState(context);
        }
    }
    
    func drawSecondTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        
        for i in 0...59{
            if i % 5 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                CGContextSaveGState(context);
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                CGContextTranslateCTM(context, translateX, translateY)
                CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
                path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
                path.lineWidth = self.bounds.size.width * percentWidth;
                color.setStroke()
                path.stroke()
                CGContextRestoreGState(context);
            }
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        self.drawFace()
    }
    
    func drawLargeNumbers(percentFontSize:CGFloat,fontColor:UIColor,percentInset:CGFloat)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            
            let largeFont = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize*2.75)
            let largeTextFontAttributes = [
                NSFontAttributeName: largeFont,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let angle = 360.0/12.0*CGFloat(index)
            let largeNumberSize = "      ".sizeWithAttributes(largeTextFontAttributes)
            if angle % 30.0 == 0
            {
                switch angle/30.0{
                case 0.0:
                    
                    let largeNumberString:NSString = "6"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 1.0:
                    
                    let largeNumberString:NSString = "5"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 2.0:
                    
                    let largeNumberString:NSString = "4"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 3.0:
                    
                    let largeNumberString:NSString = "3"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 4.0:
                    
                    let largeNumberString:NSString = "2"
                    
                    //let largeOffsetPoint = self.trigOffsetForAngle(angle, size: largeNumberOffset)
                    //let largeNumberPoint = CGPoint(x: -largeOffsetPoint.x, y: -largeOffsetPoint.y)
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 5.0:
                    
                    let largeNumberString:NSString = "1"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 6.0:
                    
                    let largeNumberString:NSString = "12"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 7.0:
                    
                    let largeNumberString:NSString = "11"
                
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)

                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    
                    break
                case 8.0:
                    
                    let largeNumberString:NSString = "10"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 9.0:
                    
                    let largeNumberString:NSString = "9"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 10.0:
                    
                    let largeNumberString:NSString = "8"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                case 11.0:
                    
                    let largeNumberString:NSString = "7"
                    
                    let largeNumberPoint = CGPoint(x: -largeNumberSize.width * 0.5, y: -largeNumberSize.height * 0.5)
                    
                    largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
                    break
                    
                default:
                    break
                }
            }
            
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            
            
            CGContextRestoreGState(context);
        }

    }
    
    func trigSquareOffsetForAngle(angle:CGFloat,width:CGFloat) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*width*0.5+width*0.5
        let y = cos(degreesToRadians(angle))*width*0.5+width*0.5
        return CGPoint(x: x, y: y)
    }
    
    func trigOffsetForAngle(angle:CGFloat,size:CGSize) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*size.width*0.5+size.width*0.5
        let y = cos(degreesToRadians(angle))*size.height*0.5+size.height*0.5
        return CGPoint(x: x, y: y)
    }
    
}

private class BGAppleWatchClockSecondHandView: BGClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.60, percentWidth: 0.01,color:self.handColor)
        
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalInRect: screwRect)
        self.handColor.setStroke()
        self.handColor.setFill()
        
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalInRect: CGRectInset(screwRect, screwRadius*0.5, screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
        
    }
}

private class BGAppleWatchClockMinuteHandView: BGAppleWatchClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.040,color:self.handColor)
    }
}

private class BGAppleWatchClockHourHandView: BGAppleWatchClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.040,color: self.handColor)
    }
}

private class BGAppleWatchClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let linePercentLength:CGFloat = 0.08
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalInRect:centerScrewRect)
        path.appendPath(screwCircle)
        
        let line = UIBezierPath(rect: CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.25, y: self.bounds.size.height*0.5-self.bounds.size.height*(linePercentLength+0.02), width: self.bounds.size.width*percentWidth*0.5, height: self.bounds.size.height*(linePercentLength+0.02)))
        path.appendPath(line)
        
        let roundedRectRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.width*0.5-handLength, width: self.bounds.size.width*percentWidth, height: handLength-self.bounds.size.height*linePercentLength)
        let roundedRect = UIBezierPath(roundedRect: roundedRectRect, cornerRadius: self.bounds.size.width*percentWidth*0.5)
        path.appendPath(roundedRect)
        
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
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawFace()
    {
        let percentFontSize:CGFloat = 0.15
        let font = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: minuteTickColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let horizontalSpacing = self.frame.size.height * 0.35
        let verticalSpacing = self.frame.size.height * 0.15
        let numberSize = "      ".sizeWithAttributes(textFontAttributes)
        let verticalBuffer = self.frame.size.height * 0.03
        let horizontalBuffer = self.frame.size.height * -0.04
        
        for index in 11...13
        {
            var numberString:NSString = String(index)
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
            numberString.drawInRect(rect, withAttributes: textFontAttributes)
        }
        for index in 2...4
        {
            let numberString:NSString = String(index)
            let point = CGPoint(x: self.bounds.size.width - numberSize.width - horizontalBuffer , y: self.bounds.size.height * 0.5 + verticalSpacing * (CGFloat(index) - 3) + numberSize.height * (0.5 * CGFloat(index) - 2.0))
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.drawInRect(rect, withAttributes: textFontAttributes)
        }
        for index in 5...7
        {
            let numberString:NSString = String(index)
            let widthNumber = (0.5 * CGFloat(index) - 3.5)
            let horizontalNumber = CGFloat(index) - 6
            let x = self.bounds.size.width * 0.5 - horizontalSpacing * horizontalNumber + numberSize.width * widthNumber
            let point = CGPoint(x: x, y: self.bounds.size.height - verticalBuffer - numberSize.height)
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.drawInRect(rect, withAttributes: textFontAttributes)
        }
        for index in 8...10
        {
            let numberString:NSString
            numberString = String(index)
            let point = CGPoint(x:horizontalBuffer , y: self.bounds.size.height * 0.5 + verticalSpacing * (CGFloat(-index) + 9) + numberSize.height * (-0.5 * CGFloat(index) + 4))
            let rect:CGRect = CGRect(origin: point, size: numberSize)
            numberString.drawInRect(rect, withAttributes: textFontAttributes)
        }
    }
    
    override func drawRect(rect: CGRect)
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
        self.drawMinuteTicksWithPercentLength(0.4, percentWidth: 0.0004,percentFontSize:0.00,tickColor: minuteTickColor,fontColor: UIColor.clearColor())
        self.drawMilliSecondTicksWithPercentLength(0.02, percentWidth: 0.004, color: secondTickColor)
        self.drawTopAndBottomDialsWithPercentLength(0.01, percentWidth: 0.004, percentFontSize: 0.035, tickColor: secondTickColor, fontColor: textColor)
    }
    
    func drawTopAndBottomDialsWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        let font = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        let textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        for i in 0...1 {
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let firstTranslateY =  (i == 0) ? self.frame.size.height * 0.20 : self.frame.size.height * 0.55
            CGContextTranslateCTM(context, 0.0, firstTranslateY)
            let handWidth = self.bounds.size.width * 0.0025
            let circle = UIBezierPath(ovalInRect:CGRect(x: self.bounds.size.width * 0.5 - handWidth * 3.0, y: self.frame.size.width*0.12, width: handWidth * 6.0, height: handWidth * 6.0))
            tickColor.setFill()
            tickColor.setStroke()
            circle.stroke()
            circle.fill()
            
            let rect = UIBezierPath(rect: CGRect(x: self.bounds.size.width * 0.5 - handWidth * 0.5, y: self.frame.size.width*0.12, width: handWidth, height: -self.frame.size.width*0.12))
            rect.stroke()
            rect.fill()
            
            for index in 0...59
            {
                CGContextSaveGState(context);
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(index)))*self.frame.size.width*0.12+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(index)))*self.frame.size.width*0.12+self.frame.size.width*0.12
                let angle = 360.0/60.0*CGFloat(index)
                let verticalBuffer = -self.frame.size.width * 0.125 * 0.15
                CGContextTranslateCTM(context, translateX, translateY)
                if angle % 90.0 == 0 && i == 1
                {
                    switch angle/90.0{
                    case 0.0:
                        let numberString:NSString = "30"
                        let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y: -y)
                        
                        numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                        
                        break
                    case 1.0:
                        
                        let numberString:NSString = "15"
                        let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                        
                        break
                    case 2.0:
                        
                        let numberString:NSString = "60"
                        let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(360.0/12.0*CGFloat(index), width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        
                        numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                        
                    case 3.0:
                        
                        let numberString:NSString = "45"
                        let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(360.0/12.0*CGFloat(index), width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                        
                        break
                        
                    default:
                        break
                    }
                }
                if angle % 180.0 == 0 && i == 0
                {
                    switch angle/180.0{
                    case 0.0:
                        let numberString:NSString = "1"
                        let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y: y + verticalBuffer * 3.0)
                        
                        numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                        
                        break
                    case 1.0:
                        
                        let numberString:NSString = "2"
                        let numberSize = numberString.sizeWithAttributes(textFontAttributes)
                        let offsetPoint = self.trigSquareOffsetForAngle(angle, width: numberSize.width)
                        let x = offsetPoint.x
                        let y = offsetPoint.y
                        
                        let point = CGPoint(x: -x, y:-y)
                        
                        numberString.drawAtPoint(point, withAttributes: textFontAttributes)
                        
                        break
                    default:
                        break
                    }
                }

                
                CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(index)))
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.0,y: -verticalBuffer))
                if index % 2 == 0
                {
                    path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength - verticalBuffer))
                }
                else
                {
                    path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength * 2.0 - verticalBuffer))

                }
                path.lineWidth = self.bounds.size.width * percentWidth;
                tickColor.setStroke()
                path.stroke()
                
                CGContextRestoreGState(context);
            }
            CGContextRestoreGState(context);
            
            
        }
    }
    
    func drawMilliSecondTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        for i in 0...299{
            if i % 25 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                CGContextSaveGState(context);
                let translateX = sin(self.degreesToRadians(360.0/300.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/300.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                CGContextTranslateCTM(context, translateX, translateY)
                CGContextRotateCTM(context, self.degreesToRadians(-360.0/300.0*CGFloat(i)))
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
                path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
                path.lineWidth = self.bounds.size.width * percentWidth;
                color.setStroke()
                path.stroke()
                CGContextRestoreGState(context);
            }
            else
            {
                let context = UIGraphicsGetCurrentContext();
                CGContextSaveGState(context);
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                CGContextTranslateCTM(context, translateX, translateY)
                CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
                path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength * 2.0))
                path.lineWidth = self.bounds.size.width * percentWidth * 2.0;
                self.minuteTickColor.setStroke()
                path.stroke()
                CGContextRestoreGState(context);
            }
        }

    }
}

private class BGAppleWatchChronoClockMinuteHandView: BGAppleWatchChronoClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.040,color:self.handColor)
    }
}

private class BGAppleWatchChronoClockHourHandView: BGAppleWatchChronoClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.040,color: self.handColor)
    }
}

private class BGAppleWatchChronoClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();

        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let linePercentLength:CGFloat = 0.08
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalInRect:centerScrewRect)
        path.appendPath(screwCircle)
        
        let line = UIBezierPath(rect: CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.25, y: self.bounds.size.height*0.5-self.bounds.size.height*(linePercentLength), width: self.bounds.size.width*percentWidth*0.5, height: self.bounds.size.height*(linePercentLength+0.02)))
        path.appendPath(line)
        
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
    
    override func drawMinuteTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        self.drawLargeNumbers(percentFontSize, fontColor: fontColor,percentInset: 0.00)
        
        for i in 0...11{
            
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
            
            CGContextTranslateCTM(context, translateX, translateY)
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/12.0*CGFloat(i)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
            path.lineWidth = self.bounds.size.width * percentWidth;
            tickColor.setStroke()
            path.stroke()
            CGContextRestoreGState(context);
            
        }
    }
    
    override func drawLargeNumbers(percentFontSize:CGFloat,fontColor:UIColor,percentInset:CGFloat)
    {
        for index in 0...23 {
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            
            let angle = 360.0/24.0*CGFloat(index)

            let translateX = sin(self.degreesToRadians(angle))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(angle - 180.0))*self.frame.size.width*(0.50 - percentInset)+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            
            let largeFont = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize*2.75)
            let largeTextFontAttributes = [
                NSFontAttributeName: largeFont,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let largeNumberSize = "     ".sizeWithAttributes(largeTextFontAttributes)
            CGContextRotateCTM(context, self.degreesToRadians(angle))
            
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
            
            largeNumberString.drawInRect(CGRect(origin: largeNumberPoint, size: largeNumberSize), withAttributes: largeTextFontAttributes)
            
            CGContextRestoreGState(context);
        }
        
    }
    
    override func drawSecondTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        
        for i in 0...59{
            if i % 5 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                CGContextSaveGState(context);
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.43+self.frame.size.width*0.5
                
                CGContextTranslateCTM(context, translateX, translateY)
                CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
                path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -percentLength))
                path.lineWidth = self.bounds.size.width * percentWidth;
                color.setStroke()
                path.stroke()
                CGContextRestoreGState(context);
            }
        }
    }

}

//MARK: - Plain

private class BGPlainClockFaceView: BGUtilityClockFaceView {
    override func drawFace()
    {
        self.drawMinuteTicksWithPercentLength(0.00, percentWidth: 0.000,percentFontSize:0.05,tickColor: UIColor.clearColor(),fontColor: textColor)
    }
    
    override func drawMinuteTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        self.drawLargeNumbers(percentFontSize, fontColor: fontColor,percentInset: 0.085)
    }
}

private class BGPlainClockMinuteHandView: BGPlainClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.015,color:self.handColor)
    }
}

private class BGPlainClockHourHandView: BGPlainClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.015,color: self.handColor)
    }
}

private class BGPlainClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth * 1.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth * 1.5, width: self.bounds.size.width*percentWidth * 3.0, height: self.bounds.size.width*percentWidth * 3.0)
        let screwCircle = UIBezierPath(ovalInRect:centerScrewRect)
        path.appendPath(screwCircle)
        
        let roundedRectRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.width*0.5-handLength, width: self.bounds.size.width*percentWidth, height: handLength)
        let roundedRect = UIBezierPath(roundedRect: roundedRectRect, cornerRadius: self.bounds.size.width*percentWidth*0.5)
        path.appendPath(roundedRect)
        
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
        let circle = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width * 0.25, self.bounds.size.height * 0.25))
        self.minuteTickColor.setFill()
        self.minuteTickColor.setStroke()
        circle.stroke()
        circle.fill()
        
        self.drawMinuteTicksWithPercentLength(0.00, percentWidth: 0.000,percentFontSize:0.15,tickColor: minuteTickColor,fontColor: textColor)
    }
    
    override func drawMinuteTicksWithPercentLength(percentLength: CGFloat, percentWidth: CGFloat, percentFontSize: CGFloat, tickColor: UIColor, fontColor: UIColor) {
        super.drawMinuteTicksWithPercentLength(percentLength, percentWidth: percentWidth, percentFontSize: percentFontSize, tickColor: tickColor, fontColor: fontColor)
        
        let circleWidth = self.bounds.size.width * percentFontSize * 0.25
        
        for index in 0...11 {
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            let angle = 360.0/12.0*CGFloat(index)
            if angle % 90.0 != 0.0
            {
                if angle < 90.0
                {
                    let circle2 = UIBezierPath(ovalInRect: CGRect(x: -circleWidth, y: -circleWidth , width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
                else if angle < 180.0 && angle > 90.0
                {
                    let circle2 = UIBezierPath(ovalInRect: CGRect(x: -circleWidth * 0.5, y: circleWidth * 0.5, width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
                else if angle < 270.0 && angle > 180.0
                {
                    let circle2 = UIBezierPath(ovalInRect: CGRect(x: circleWidth * 0.5, y: circleWidth * 0.5, width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
                else
                {
                    let circle2 = UIBezierPath(ovalInRect: CGRect(x: circleWidth * 0.5, y: -circleWidth, width: circleWidth, height: circleWidth))
                    self.minuteTickColor.setFill()
                    self.minuteTickColor.setStroke()
                    circle2.stroke()
                    circle2.fill()
                }
            }
            CGContextRestoreGState(context)
        }
    }
}

private class BGMinimalClockSecondHandView: BGMinimalClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.47, percentWidth: 0.01,color:self.handColor)
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalInRect: screwRect)
        self.handColor.setStroke()
        self.handColor.setFill()
        
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalInRect: CGRectInset(screwRect, screwRadius*0.5, screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
        
    }
}

private class BGMinimalClockMinuteHandView: BGMinimalClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.47, percentWidth: 0.015,color:self.handColor)
    }
}

private class BGMinimalClockHourHandView: BGMinimalClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.015,color: self.handColor)
    }
}

private class BGMinimalClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let lineWidth = self.bounds.size.width*percentWidth
        
        let tapperFactor = self.bounds.size.width * 0.005
        let stub = self.bounds.size.height * 0.03
        
        let path = UIBezierPath()
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalInRect:centerScrewRect)
        path.appendPath(screwCircle)
        
        let line = UIBezierPath()
        line.moveToPoint(CGPoint(x: self.bounds.size.width*0.5 - lineWidth, y: self.bounds.size.height*0.5 + stub - tapperFactor))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor, y: self.bounds.size.height*0.5 + stub), controlPoint: CGPoint(x: self.bounds.size.width*0.5 - lineWidth, y: self.bounds.size.height*0.5 + stub))
        line.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor, y: self.bounds.size.height*0.5 + stub))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5 + lineWidth, y: self.bounds.size.height*0.5 + stub - tapperFactor), controlPoint: CGPoint(x: self.bounds.size.width*0.5 + lineWidth, y: self.bounds.size.height*0.5 + stub))
        line.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor, y: self.bounds.size.height*0.5 - handLength + tapperFactor))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor * 2.0, y: self.bounds.size.height*0.5 - handLength ), controlPoint: CGPoint(x: self.bounds.size.width*0.5 + lineWidth - tapperFactor, y: self.bounds.size.height*0.5 - handLength))
        line.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor * 2.0, y: self.bounds.size.height*0.5 - handLength))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor, y: self.bounds.size.height*0.5 - handLength + tapperFactor), controlPoint: CGPoint(x: self.bounds.size.width*0.5 - lineWidth + tapperFactor, y: self.bounds.size.height*0.5 - handLength))
        line.closePath()
        
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
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.46, percentWidth: 0.045,color:self.handColor)
    }
}

private class BGBigBenClockHourHandView: BGBigBenClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.045,color: self.handColor)
    }
}

private class BGBigBenClockHandView: BGClockHandView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        color.setFill()
        color.setStroke()
        let context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        
        let fanRadius = self.bounds.size.width*percentWidth*2.0
        let verticalBuffer = self.bounds.size.width*0.02
        
        let line = UIBezierPath()
        line.moveToPoint(CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.width*0.5+fanRadius))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5+fanRadius*0.5,
            y: self.bounds.size.width*0.5+fanRadius),
            controlPoint: CGPoint(x: self.bounds.size.width*0.5+fanRadius*0.25,
                y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5+self.bounds.size.width*percentWidth*0.5*0.40, y: self.bounds.size.width*0.5), controlPoint: CGPoint(x: self.bounds.size.width*0.5+fanRadius*0.25, y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5*0.40, y: self.bounds.size.width*0.5))
        line.addQuadCurveToPoint(CGPoint(x:self.bounds.size.width*0.5-fanRadius*0.5, y: self.bounds.size.width*0.5+fanRadius), controlPoint: CGPoint(x: self.bounds.size.width*0.5-fanRadius*0.25, y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.width*0.5+fanRadius), controlPoint: CGPoint(x: self.bounds.size.width*0.5-fanRadius*0.25, y: self.bounds.size.width*0.5+fanRadius-verticalBuffer))
        line.closePath()
        
        line.stroke()
        line.fill()
        
        let line2 = UIBezierPath()
        line2.moveToPoint(CGPoint(x: self.bounds.size.width*0.5-self.bounds.size.width*0.4*percentWidth, y: self.bounds.size.height*0.5))
        line2.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5-self.bounds.size.width*0.25*percentWidth, y: self.bounds.size.height*0.5-handLength+self.bounds.size.width*0.5*percentWidth))
        line2.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5, y: self.bounds.size.height*0.5-handLength))
        line2.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5+self.bounds.size.width*0.25*percentWidth, y: self.bounds.size.height*0.5-handLength+self.bounds.size.width*0.5*percentWidth))
        line2.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5+self.bounds.size.width*percentWidth*0.4, y: self.bounds.size.height*0.5))
        line2.stroke()
        line2.fill()

        CGContextRestoreGState(context)
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5*1.25, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5*1.25, width: self.bounds.size.width*percentWidth*1.25, height: self.bounds.size.width*percentWidth*1.2)
        let screwCircle = UIBezierPath(ovalInRect:centerScrewRect)
        screwCircle.stroke()
        screwCircle.fill()
        
    }
}


private class BGBigBenClockFaceView: BGClockFaceView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawFace()
    {
        self.textColor.setStroke()
        
        let circle = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width*0.02, self.bounds.size.height*0.02))
        circle.lineWidth = self.bounds.size.width*0.04
        circle.stroke()
        
        let circle2 = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width*0.07, self.bounds.size.height*0.07))
        circle2.lineWidth = self.bounds.size.width*0.01
        circle2.stroke()
        
        let circle3 = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width*0.14, self.bounds.size.height*0.14))
        circle3.lineWidth = self.bounds.size.width*0.01
        circle3.stroke()
        
        let circle4 = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width*0.17, self.bounds.size.height*0.17))
        circle4.lineWidth = self.bounds.size.width*0.0125
        circle4.stroke()
        
        let circle5 = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width*0.25, self.bounds.size.height*0.25))
        circle5.lineWidth = self.bounds.size.width*0.01
        circle5.stroke()
        
        let circle6 = UIBezierPath(ovalInRect: CGRectInset(self.bounds, self.bounds.size.width*0.27, self.bounds.size.height*0.27))
        circle6.lineWidth = self.bounds.size.width*0.01
        circle6.stroke()
        
        self.drawSecondTicksWithPercentLength(0.04, percentWidth: 0.010,color: self.secondTickColor)
        self.drawMinuteTicksWithPercentLength(0.0, percentWidth: 0.00,percentFontSize:0.08,tickColor: minuteTickColor,fontColor: self.textColor)
    }
    
    func drawMinuteTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,percentFontSize:CGFloat,tickColor:UIColor,fontColor:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            let font = self.faceFont!.fontWithSize(self.bounds.size.height * percentFontSize)
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName: textStyle
            ]
            
            let verticalBuffer = self.bounds.size.height*0.01
            let angle = 360.0/12.0*CGFloat(index)
            
            
            CGContextRotateCTM(context, self.degreesToRadians(-angle+180.0))
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
            
            let numberSize = numberString.sizeWithAttributes(textFontAttributes)
            let point = CGPoint(x: -numberSize.width*0.5, y: self.bounds.size.height*0.08-verticalBuffer+numberSize.height)
            numberString.drawAtPoint(point, withAttributes: textFontAttributes)
            
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: self.bounds.size.width*0.04))
            path.addLineToPoint(CGPoint(x: -verticalBuffer,y: self.bounds.size.width*0.04+verticalBuffer))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width*0.04+verticalBuffer*2.0))
            path.addLineToPoint(CGPoint(x: verticalBuffer,y: self.bounds.size.width*0.04+verticalBuffer))
            path.closePath()
            path.lineWidth = self.bounds.size.width * percentWidth;
            
            let rect = UIBezierPath(rect: CGRect(x: -verticalBuffer, y: self.bounds.size.width*0.04+verticalBuffer*2.0, width: verticalBuffer*2.0, height: self.bounds.size.height*0.09))
            path.appendPath(rect)
            
            let path2 = UIBezierPath()
            path2.moveToPoint(CGPoint(x: 0.0, y: self.bounds.size.width*0.04+verticalBuffer*2.0+self.bounds.size.height*0.09))
            path2.addLineToPoint(CGPoint(x: -verticalBuffer, y: self.bounds.size.width*0.04+verticalBuffer*3.0+self.bounds.size.height*0.09))
            path2.addLineToPoint(CGPoint(x: 0.0, y: self.bounds.size.width*0.04+verticalBuffer*4.0+self.bounds.size.height*0.09))
            path2.addLineToPoint(CGPoint(x: verticalBuffer, y: self.bounds.size.width*0.04+verticalBuffer*3.0+self.bounds.size.height*0.09))
            path2.closePath()
            path.appendPath(path2)
            
            let path3 = UIBezierPath()
            path3.moveToPoint(CGPoint(x: -verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8+verticalBuffer))
            path3.addLineToPoint(CGPoint(x: -verticalBuffer, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            path3.addLineToPoint(CGPoint(x: -verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8-verticalBuffer))
            path3.addLineToPoint(CGPoint(x: -verticalBuffer*3.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            
            
            path3.closePath()
            path.appendPath(path3)
            
            let path4 = UIBezierPath()
            path4.moveToPoint(CGPoint(x: verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8-verticalBuffer))
            path4.addLineToPoint(CGPoint(x: verticalBuffer, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            path4.addLineToPoint(CGPoint(x: verticalBuffer*2.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8+verticalBuffer))
            path4.addLineToPoint(CGPoint(x: verticalBuffer*3.0, y: (self.bounds.size.width*0.04+self.bounds.size.height*0.09)*0.8))
            
            
            path4.closePath()
            path.appendPath(path4)
            
            let path5 = UIBezierPath()
            path5.moveToPoint(CGPoint(x: 0.0, y: verticalBuffer*2.0+self.bounds.size.height*0.23))
            path5.addLineToPoint(CGPoint(x: -verticalBuffer, y: verticalBuffer*3.0+self.bounds.size.height*0.23))
            path5.addLineToPoint(CGPoint(x: 0.0, y: verticalBuffer*4.0+self.bounds.size.height*0.23))
            path5.addLineToPoint(CGPoint(x: verticalBuffer, y:verticalBuffer*3.0+self.bounds.size.height*0.23))
            
            path5.closePath()
            path.appendPath(path5)
            
            tickColor.setStroke()
            tickColor.setFill()
            
            path.stroke()
            path.fill()
            
            CGContextRestoreGState(context);
            
        }
        
        for index in 0...23{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let angle = 360.0/24.0*CGFloat(index)
            
            let translateX = sin(self.degreesToRadians(angle))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(angle))*self.frame.size.width*0.5+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            
            CGContextRotateCTM(context, self.degreesToRadians(-angle+180.0))
            
            let path6 = UIBezierPath()
            path6.moveToPoint(CGPoint(x: 0.0, y: self.bounds.size.height*0.275))
            path6.addLineToPoint(CGPoint(x: -self.bounds.size.width*0.035, y: self.bounds.size.height*0.375))
            path6.addCurveToPoint(CGPoint(x: 0.0, y: self.bounds.size.height*0.5), controlPoint1: CGPoint(x: self.bounds.size.width*0.035, y: self.bounds.size.height*0.5), controlPoint2: CGPoint(x: 0.0, y: self.bounds.size.height*0.45))
            
            let path7 = UIBezierPath()
            path7.moveToPoint(CGPoint(x: 0.0, y: self.bounds.size.height*0.275))
            path7.addLineToPoint(CGPoint(x: self.bounds.size.width*0.035, y: self.bounds.size.height*0.375))
            path7.addCurveToPoint(CGPoint(x: 0.0, y: self.bounds.size.height*0.5), controlPoint1: CGPoint(x: -self.bounds.size.width*0.035, y: self.bounds.size.height*0.5), controlPoint2: CGPoint(x: 0.0, y: self.bounds.size.height*0.45))
            path6.appendPath(path7)
            
            tickColor.setStroke()
            tickColor.setFill()
            
            path6.lineWidth = self.bounds.size.width * 0.005
            path6.stroke()
            
            CGContextRestoreGState(context);
            
        }
    }
    
    func drawSecondTicksWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        
        for i in 0...59{
            if i % 5 != 0
            {
                let context = UIGraphicsGetCurrentContext();
                CGContextSaveGState(context);
                let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
                
                CGContextTranslateCTM(context, translateX, translateY)
                CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(i)))
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.0,y: -self.bounds.size.height*0.15))
                path.addLineToPoint(CGPoint(x: 0.0,y: -self.bounds.size.height*0.06))
                path.lineWidth = self.bounds.size.width * percentWidth;
                path.lineCapStyle = .Round
                color.setStroke()
                path.stroke()
                CGContextRestoreGState(context);
            }
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        self.drawFace()
    }
    
    func trigSquareOffsetForAngle(angle:CGFloat,width:CGFloat) ->CGPoint
    {
        let x = sin(self.degreesToRadians(angle))*width*0.5+width*0.5
        let y = cos(degreesToRadians(angle))*width*0.5+width*0.5
        return CGPoint(x: x, y: y)
    }
    
    func trigOffsetForAngle(angle:CGFloat,size:CGSize) ->CGPoint
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
    var amPMLabel = UILabel(frame: CGRectZero)
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
                self.faceFont = UIFont.systemFontOfSize(squareHeight * 0.80)
            }
            return self.faceFont!.fontWithSize(squareHeight * 0.80)
        }
    }
    
    var amPMFont:UIFont{
        get{
            if self.faceFont == nil
            {
                self.faceFont = UIFont.systemFontOfSize(squareHeight * 0.80 * 0.20)
            }
            return self.faceFont!.fontWithSize(squareHeight * 0.80 * 0.20)
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
            let tS = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            tS.alignment = NSTextAlignment.Center
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
        
        hourNumberView = BGFlipNumberView(frame:CGRectZero)
        minuteNumberView = BGFlipNumberView(frame:CGRectZero)
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
        let hourRect = CGRect(x: buffer, y: frame.size.height * 0.5 - squareHeight * 0.5, width: squareHeight, height: squareHeight)
        let minutesRect = CGRect(x: frame.size.width * 0.5 + buffer * 0.5, y: frame.size.height * 0.5 - squareHeight * 0.5, width: squareHeight, height: squareHeight)
        
        self.hourNumberView.frame = hourRect
        self.minuteNumberView.frame = minutesRect
        
        let amSize = "PM".sizeWithAttributes(self.amPMFontAttributes)
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
        
        hourNumberView = BGFlipNumberView(frame:CGRectZero)
        minuteNumberView = BGFlipNumberView(frame:CGRectZero)
        
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
        let hourRect = CGRect(x: self.buffer, y: self.frame.size.height * 0.5 - self.squareHeight * 0.5, width: self.squareHeight, height: self.squareHeight)
        let minutesRect = CGRect(x: self.frame.size.width * 0.5 + self.buffer * 0.5, y: self.frame.size.height * 0.5 - self.squareHeight * 0.5, width: self.squareHeight, height: self.squareHeight)
        
        self.hourNumberView.frame = hourRect
        self.minuteNumberView.frame = minutesRect
        
        let amSize = "PM".sizeWithAttributes(amPMFontAttributes)
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
        
        let amSize = "PM".sizeWithAttributes(amPMFontAttributes)
        let amPMRect = CGRect(x: buffer * 2.0, y: self.bounds.size.height * 0.5 + squareHeight * 0.5 - amSize.height, width: amSize.width, height: amSize.height)
        self.amPMLabel.frame = amPMRect
    }
    
    func animateMinuteFlipWithMinute(newMinute:Int)
    {
        let newNumberView = BGFlipNumberView(frame: self.minuteNumberView.frame)
        newNumberView.cardColor = self.minuteTickColor
        
        let mString = self.minutes<10 ? "0"+"\(newMinute)" : "\(newMinute)"
        let minuteString = NSAttributedString(string: mString, attributes: self.textFontAttributes)
        newNumberView.numberString = minuteString
        self.insertSubview(newNumberView, belowSubview: self.minuteNumberView)
        
        BGFlipTransition.transitionFromView(self.minuteNumberView,toView:newNumberView,dur: 0.3,sty: .BackwardVerticalRegularPerspective,act: .None,completion: {(finished:Bool) in
            self.minuteNumberView.removeFromSuperview()
            self.minuteNumberView = newNumberView
            self.minutes = newMinute
            self.minuteAnimating = false
        })
        
    }
    
    func animateHourFlipWithHour(newHour:Int)
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
        
        BGFlipTransition.transitionFromView(self.hourNumberView,toView:newNumberView,dur: 0.3,sty: .BackwardVerticalRegularPerspective,act: .None ,completion: {(finished:Bool) in
            self.hourNumberView.removeFromSuperview()
            self.hourNumberView = newNumberView
            self.hour = newHour
            self.hourAnimating = false
            self.bringSubviewToFront(self.amPMLabel)
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
        self.cardColor = UIColor.clearColor()
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.cardColor = UIColor.clearColor()
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawRect(rect: CGRect)
    {
        self.cardColor.setFill()
        self.cardColor.setStroke()
        
        let numberPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        numberPath.addClip()
        numberPath.stroke()
        numberPath.fill()
        
        if self.numberString != nil
        {
            self.numberString!.drawInRect(self.bounds)
        }
        else
        {
            let font = UIFont.systemFontOfSize(self.bounds.height * 0.80)
            let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Right
            let textFontAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: UIColor.grayColor(),
                NSParagraphStyleAttributeName: textStyle
            ]
            let tempString = NSAttributedString(string: "00", attributes: textFontAttributes)
            tempString.drawInRect(self.bounds)
        }
        
        let context = UIGraphicsGetCurrentContext();

        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), self.bounds.size.height * 0.10, UIColor(white: 0.0, alpha: 0.80).CGColor)
        
        let flipBreak = UIBezierPath()
        flipBreak.moveToPoint(CGPoint(x: 0.0, y: self.bounds.size.height * 0.5))
        flipBreak.addLineToPoint(CGPoint(x:  self.bounds.size.width, y: self.bounds.size.height * 0.5))
        UIColor.blackColor().setStroke()
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
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    override func drawFace()
    {
        self.minuteTickColor.setFill()
        self.minuteTickColor.setStroke()
        
        let lineWidth = self.bounds.size.width * 0.03
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height*0.075))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height*0.345), controlPoint1: CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height * 0.075), controlPoint2: CGPoint(x: self.bounds.size.width * 0.1548, y: self.bounds.size.height*0.2341))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.475), controlPoint1: CGPoint(x: self.bounds.size.width * 0.3352, y: self.bounds.size.height * 0.4559), controlPoint2: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.475))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.585), controlPoint1: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height * 0.475), controlPoint2: CGPoint(x: self.bounds.size.width * 0.3665, y: self.bounds.size.height*0.5678))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535), controlPoint1: CGPoint(x: self.bounds.size.width * 0.4235, y: self.bounds.size.height * 0.6022), controlPoint2: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.515, y: self.bounds.size.height*0.615), controlPoint1: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height * 0.535), controlPoint2: CGPoint(x: self.bounds.size.width * 0.5007, y: self.bounds.size.height*0.4945))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height*0.765), controlPoint1: CGPoint(x: self.bounds.size.width * 0.5293, y: self.bounds.size.height * 0.7355), controlPoint2: CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height*0.765))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.605, y: self.bounds.size.height*0.815), controlPoint1: CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height * 0.765), controlPoint2: CGPoint(x: self.bounds.size.width * 0.5986, y: self.bounds.size.height*0.7844))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965), controlPoint1: CGPoint(x: self.bounds.size.width * 0.6317, y: self.bounds.size.height * 0.9289), controlPoint2: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.715, y: self.bounds.size.height*0.905), controlPoint1: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height * 0.965), controlPoint2: CGPoint(x: self.bounds.size.width * 0.6804, y: self.bounds.size.height*1.045))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.785, y: self.bounds.size.height*0.725), controlPoint1: CGPoint(x: self.bounds.size.width * 0.7496, y: self.bounds.size.height * 0.765), controlPoint2: CGPoint(x: self.bounds.size.width * 0.785, y: self.bounds.size.height*0.725))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.865, y: self.bounds.size.height*0.405), controlPoint1: CGPoint(x: self.bounds.size.width * 0.785, y: self.bounds.size.height * 0.725), controlPoint2: CGPoint(x: self.bounds.size.width * 0.8899, y: self.bounds.size.height*0.5201))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.755, y: self.bounds.size.height*0.265), controlPoint1: CGPoint(x: self.bounds.size.width * 0.8401, y: self.bounds.size.height * 0.2899), controlPoint2: CGPoint(x: self.bounds.size.width * 0.755, y: self.bounds.size.height*0.265))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.555, y: self.bounds.size.height*0.115), controlPoint1: CGPoint(x: self.bounds.size.width * 0.755, y: self.bounds.size.height * 0.265), controlPoint2: CGPoint(x: self.bounds.size.width * 0.595, y: self.bounds.size.height*0.1971))
        
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.355, y: self.bounds.size.height*0.015), controlPoint1: CGPoint(x: self.bounds.size.width * 0.515, y: self.bounds.size.height * 0.0329), controlPoint2: CGPoint(x: self.bounds.size.width * 0.355, y: self.bounds.size.height*0.015))
        path.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.245, y: self.bounds.size.height*0.075), controlPoint1: CGPoint(x: self.bounds.size.width * 0.355, y: self.bounds.size.height * 0.015), controlPoint2: CGPoint(x: self.bounds.size.width * 0.2837, y: self.bounds.size.height*0.008))
        
        let path2 = UIBezierPath();
        path2.moveToPoint(CGPoint(x: self.bounds.size.width * 0.41, y: self.bounds.size.height*0.47))
        path2.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height*0.585), controlPoint1: CGPoint(x: self.bounds.size.width * 0.395, y: self.bounds.size.height * 0.475), controlPoint2: CGPoint(x: self.bounds.size.width * 0.3665, y: self.bounds.size.height*0.5678))
        path2.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535), controlPoint1: CGPoint(x: self.bounds.size.width * 0.4235, y: self.bounds.size.height * 0.6022), controlPoint2: CGPoint(x: self.bounds.size.width * 0.445, y: self.bounds.size.height*0.535))
        path2.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width * 0.41, y: self.bounds.size.height*0.47), controlPoint: CGPoint(x: self.bounds.size.width * 0.40, y: self.bounds.size.height*0.56))
        path2.stroke()
        path2.fill()
        
        let path3 = UIBezierPath();
        path3.moveToPoint(CGPoint(x: self.bounds.size.width * 0.605, y: self.bounds.size.height*0.815))
        path3.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965), controlPoint1: CGPoint(x: self.bounds.size.width * 0.6317, y: self.bounds.size.height * 0.9289), controlPoint2: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height*0.965))
        path3.addCurveToPoint(CGPoint(x: self.bounds.size.width * 0.715, y: self.bounds.size.height*0.905), controlPoint1: CGPoint(x: self.bounds.size.width * 0.645, y: self.bounds.size.height * 0.965), controlPoint2: CGPoint(x: self.bounds.size.width * 0.6804, y: self.bounds.size.height*1.045))
        path3.addLineToPoint(CGPoint(x: self.bounds.size.width * 0.73, y: self.bounds.size.height*0.815))
        path3.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width * 0.605, y: self.bounds.size.height*0.815), controlPoint: CGPoint(x: self.bounds.size.width * 0.665, y: self.bounds.size.height*0.90))
        path3.stroke()
        path3.fill()
        
        path.lineWidth = lineWidth
        path.stroke()
        
        let context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextRotateCTM(context, self.degreesToRadians(-10.0))
        
        var font = self.faceFont!.fontWithSize(self.bounds.size.height * 0.08)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        var textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string12 = NSAttributedString(string: "12", attributes: textFontAttributes)
        string12.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.20, y: self.bounds.size.height*0.17))
        
        let string11 = NSAttributedString(string: "11", attributes: textFontAttributes)
        string11.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.19, y: self.bounds.size.height*0.26))
        
        let string10 = NSAttributedString(string: "10", attributes: textFontAttributes)
        string10.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.23, y: self.bounds.size.height*0.34))
        
        font = self.faceFont!.fontWithSize(self.bounds.size.height * 0.12)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string9 = NSAttributedString(string: "9", attributes: textFontAttributes)
        string9.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.32, y: self.bounds.size.height*0.43))
        
        let string8 = NSAttributedString(string: "8", attributes: textFontAttributes)
        string8.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.40, y: self.bounds.size.height*0.51))
        
        font = self.faceFont!.fontWithSize(self.bounds.size.height * 0.16)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string7 = NSAttributedString(string: "7", attributes: textFontAttributes)
        string7.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.42, y: self.bounds.size.height*0.64))
        
        let string6 = NSAttributedString(string: "6", attributes: textFontAttributes)
        string6.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.48, y: self.bounds.size.height*0.79))
        
        font = self.faceFont!.fontWithSize(self.bounds.size.height * 0.20)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        
        CGContextRotateCTM(context, self.degreesToRadians(10.0))
        
        
        let string5 = NSAttributedString(string: "5", attributes: textFontAttributes)
        string5.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.79, y: self.bounds.size.height*0.35))
        
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        
        CGContextRotateCTM(context, self.degreesToRadians(-10.0))
        
        let string4 = NSAttributedString(string: "4", attributes: textFontAttributes)
        string4.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.62, y: self.bounds.size.height*0.38))
        
        font = self.faceFont!.fontWithSize(self.bounds.size.height * 0.18)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        
        CGContextRotateCTM(context, self.degreesToRadians(-30.0))
        
        let string3 = NSAttributedString(string: "3", attributes: textFontAttributes)
        string3.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.33, y: self.bounds.size.height*0.43))
        
        font = self.faceFont!.fontWithSize(self.bounds.size.height * 0.12)
        textFontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: self.textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let string2 = NSAttributedString(string: "2", attributes: textFontAttributes)
        string2.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.30, y: self.bounds.size.height*0.30))
        
        let string1 = NSAttributedString(string: "1", attributes: textFontAttributes)
        string1.drawAtPoint(CGPoint(x: self.bounds.size.width * 0.22, y: self.bounds.size.height*0.18))
        
        CGContextRestoreGState(context);
        
    }
}

private class BGMeltingClockMinuteHandView: BGMeltingClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.45, percentWidth: 0.035,color:self.handColor)
    }
}

private class BGMeltingClockHourHandView: BGMeltingClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.30, percentWidth: 0.035,color: self.handColor)
    }
}

private class BGMeltingClockSecondHandView: BGAppleWatchClockSecondHandView {
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        self.drawHandWithPercentLength(0.60, percentWidth: 0.01,color:self.handColor)
        
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalInRect: screwRect)
        self.handColor.setStroke()
        self.handColor.setFill()
        
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalInRect: CGRectInset(screwRect, screwRadius*0.5, screwRadius*0.5))
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
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let handLength = self.bounds.size.height * percentLength
        let lineWidth = self.bounds.size.width*percentWidth;
        
        color.setFill()
        color.setStroke()
        
        let path = UIBezierPath()
        path.lineCapStyle = .Round
        let centerScrewRect = CGRect(x: self.bounds.size.width*0.5-self.bounds.size.width*percentWidth*0.5, y: self.bounds.size.height*0.5-self.bounds.size.height*percentWidth*0.5, width: self.bounds.size.width*percentWidth, height: self.bounds.size.width*percentWidth)
        let screwCircle = UIBezierPath(ovalInRect:centerScrewRect)
        path.appendPath(screwCircle)
        
        let line = UIBezierPath()
        line.moveToPoint(CGPoint(x: self.bounds.size.width * 0.5 - lineWidth * 0.25, y: self.bounds.size.height * 0.5))
        line.addLineToPoint(CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5 - handLength));
        line.addLineToPoint(CGPoint(x: self.bounds.size.width * 0.5 + lineWidth * 0.25, y: self.bounds.size.height * 0.5))
        line.stroke()
        line.fill()
        
        let line2 = UIBezierPath()
        line2.moveToPoint(CGPoint(x:self.bounds.size.width * 0.5 - lineWidth * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75))
        line2.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75 + lineWidth * 0.5), controlPoint: CGPoint (x: self.bounds.size.width * 0.5 - lineWidth * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75 + lineWidth * 0.5))
        line2.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width * 0.5 + lineWidth * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75), controlPoint: CGPoint (x: self.bounds.size.width * 0.5 + lineWidth * 0.5, y: self.bounds.size.height * 0.5 - handLength * 0.75 + lineWidth * 0.5))
        line2.addQuadCurveToPoint(CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5 - handLength), controlPoint: CGPoint(x:self.bounds.size.width * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75))
        line2.addQuadCurveToPoint(CGPoint(x:self.bounds.size.width * 0.5 - lineWidth * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75), controlPoint: CGPoint(x:self.bounds.size.width * 0.5,y:self.bounds.size.height * 0.5 - handLength * 0.75))
        path.appendPath(line2)
        
        path.stroke()
        path.fill()
        
    }
    
    func degreesToRadians(degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat(M_PI) / 180.0
    }
}


//MARK: - Swiss/Base Class

private class BGClockSecondHandView: BGClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.40, percentWidth: 0.01,color:self.handColor)
        
        
        let screwRadius:CGFloat = self.bounds.size.width * 0.015
        let screwRect = CGRect(x: self.bounds.size.width * 0.5 - screwRadius, y: self.bounds.size.height * 0.5 - screwRadius, width: screwRadius * 2.0, height: screwRadius * 2.0)
        let screwCircle = UIBezierPath(ovalInRect: screwRect)
        screwCircle.fill()
        screwCircle.stroke()
        
        let whiteScrewCircle = UIBezierPath(ovalInRect: CGRectInset(screwRect, screwRadius*0.5, screwRadius*0.5))
        secondHandScrewColor.setFill()
        secondHandScrewColor.setStroke()
        whiteScrewCircle.fill()
        whiteScrewCircle.stroke()
        
    }
    
    override func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        color.setFill()
        color.setStroke()
        
        CGContextSaveGState(context);
        
        
        let handLength = self.bounds.size.height * percentLength
        let path = UIBezierPath()
        let startingY = self.bounds.size.height * 0.6 - handLength
        path .moveToPoint(CGPoint(x: self.bounds.size.width*0.5, y: startingY))
        path.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5, y: startingY + handLength))
        path.lineWidth = self.bounds.size.width * percentWidth;
        color.setStroke()
        
        let radius:CGFloat = self.bounds.size.width * 0.045
        
        let circle = UIBezierPath(ovalInRect: CGRect(x: self.bounds.size.width*0.5 - radius, y: startingY - radius, width: radius * 2.0, height: radius * 2.0))
        
        
        path.appendPath(circle)
        
        
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let pathCopy = path.copy();
        let cgPathShadowPath = CGPathCreateCopyByStrokingPath(pathCopy.CGPath, nil, pathCopy.lineWidth, pathCopy.lineCapStyle, pathCopy.lineJoinStyle, pathCopy.miterLimit);
        
        let shadowPath = UIBezierPath(CGPath: cgPathShadowPath!)
        
        shadowPath.stroke()
        shadowPath.fill()
        
        CGContextRestoreGState(context);
        
        path.stroke()
        path.fill()
    }
}

private class BGClockMinuteHandView: BGClockHandView
{
    override func drawRect(rect: CGRect)
    {
        self.drawHandWithPercentLength(0.50, percentWidth: 0.045,color:self.handColor)
    }
}

private class BGClockHourHandView: BGClockHandView
{
    override func drawRect(rect: CGRect)
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
        self.secondHandScrewColor = UIColor.whiteColor()
        self.handColor = UIColor.blackColor()
        self.hasDropShadow = false
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.secondHandScrewColor = UIColor.whiteColor()
        self.handColor = UIColor.blackColor()
        self.hasDropShadow = false

        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        
        
    }
    
    func drawHandWithPercentLength(percentLength:CGFloat,percentWidth:CGFloat,color:UIColor)
    {
        let context = UIGraphicsGetCurrentContext();
        
        if self.hasDropShadow
        {
            CGContextSetShadowWithColor(context, CGSizeMake(0, self.bounds.size.height * 0.015), self.bounds.size.height * 0.015, UIColor(white: 0.0, alpha: 0.30).CGColor)
        }
        
        let handLength = self.bounds.size.height * percentLength
        let path = UIBezierPath()
        let startingY = self.bounds.size.height * 0.6 - handLength
        path .moveToPoint(CGPoint(x: self.bounds.size.width*0.5, y: startingY))
        path.addLineToPoint(CGPoint(x: self.bounds.size.width*0.5, y: startingY + handLength))
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
        self.minuteTickColor = UIColor.blackColor()
        self.secondTickColor = UIColor.blackColor()
        self.textColor = UIColor.blackColor()
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.minuteTickColor = UIColor.blackColor()
        self.secondTickColor = UIColor.blackColor()
        self.textColor = UIColor.blackColor()
        
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        self.contentMode = .Redraw
        self.opaque = false
    }
    
    func drawFace()
    {
        self.drawMinuteTicksWithColor(minuteTickColor)
        self.drawSecondTicksWithColor(secondTickColor)
    }
    
    func drawMinuteTicksWithColor(color:UIColor)
    {
        for index in 0...11{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/12.0*CGFloat(index)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            CGContextTranslateCTM(context, translateX, translateY)
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/12.0*CGFloat(index)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -0.125))
            path.lineWidth = self.bounds.size.width * 0.04;
            color.setStroke()
            path.stroke()
            CGContextRestoreGState(context);
        }
    }
    
    func drawSecondTicksWithColor(color:UIColor)
    {
        for i in 0...59{
            let context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            let translateX = sin(self.degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            let translateY = cos(degreesToRadians(360.0/60.0*CGFloat(i)))*self.frame.size.width*0.5+self.frame.size.width*0.5
            
            CGContextTranslateCTM(context, translateX, translateY)
            CGContextRotateCTM(context, self.degreesToRadians(-360.0/60.0*CGFloat(i)))
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: 0.0,y: 0.0))
            path.addLineToPoint(CGPoint(x: 0.0,y: self.bounds.size.width * -0.03))
            path.lineWidth = self.bounds.size.width * 0.0075;
            color.setStroke()
            path.stroke()
            CGContextRestoreGState(context);
        }
    }
    
    override func drawRect(rect: CGRect)
    {
        self.drawFace()
    }
    
    func degreesToRadians(degrees:CGFloat) -> CGFloat
    {
        return degrees * CGFloat(M_PI) / 180.0
    }
}
