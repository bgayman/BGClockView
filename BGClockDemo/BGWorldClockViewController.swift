//
//  BGWorldClockViewController.swift
//  BGClockDemo
//
//  Created by Brad G. on 3/11/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit
import Foundation

private let reuseIdentifier = "Cell"
private let timeZoneKey = "TimeZones"

class BGWorldClockViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,CityTableDelegate,UIWebViewDelegate {
    
    @IBOutlet weak var imageViewHolder: UIView!
    @IBOutlet weak var nightMapImageView: UIImageView!
    @IBOutlet weak var dayMapImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var lastMaskUpdate = NSDate()
    
    var sunsetPointArray = [CGPoint]()
    lazy var pointsDictionary:JSON = {
        let fileName = String(Int(self.view.bounds.size.width))
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json")
        let data = NSData(contentsOfFile: filePath!)
        let json = JSON(data: data!)
        return json
    }()
    var timeZoneArray = [TimeZoneLocation]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.settingsButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "FontAwesome", size: 22.0)!], forState: .Normal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.redrawMap), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let timeZoneManager = appDelegate.timeZoneManager
        if let timeZoneNameArray = NSUserDefaults.standardUserDefaults().objectForKey(timeZoneKey) as? NSArray
        {
            for index in 0...timeZoneNameArray.count - 1
            {
                if let string:NSString = timeZoneNameArray[index] as? NSString
                {
                    if let timeZoneLocation = timeZoneManager.timeZoneLocationForTimeZoneName(string as String)
                    {
                        timeZoneArray.append(timeZoneLocation)
                    }
                }
            }
        }
        else
        {
            if let timeZoneLocation = timeZoneManager.timeZoneLocationForTimeZoneName("America/New_York")
            {
                timeZoneArray.append(timeZoneLocation)
            }
        }
        NSTimer.scheduledTimerWithTimeInterval(60.0 * 2.0, target: self, selector: #selector(BGWorldClockViewController.updateClocks), userInfo: nil, repeats: true)
        self.modelSunlightCurve()
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.redrawMap()
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
        self.tabBarController?.tabBar.translucent = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timeZoneArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ClockCollectionViewCell
        
        if self.timeZoneArray[indexPath.row].tempString != nil
        {
            cell.timeZoneLocation = self.timeZoneArray[indexPath.row]
        }
        else
        {
            let timeZoneLocal = self.timeZoneArray[indexPath.row]
            cell.timeZoneLocation = timeZoneLocal
            if WebServiceManager().kWUndergroundAPIKey != "" {
                WebServiceManager().fetchWeatherAndAstronomyForTimeZoneLocation(self.timeZoneArray[indexPath.row], mainThreadCompletionBlock: {(success:Bool,timeZoneLocation:TimeZoneLocation) in
                    if success{
                        self.timeZoneArray[indexPath.row] = timeZoneLocation
                        cell.timeZoneLocation = timeZoneLocation
                    }
                })
            }
            
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        if self.collectionView!.bounds.size.width / 3.0 < self.collectionView.bounds.size.height
        {
            return CGSize(width: self.collectionView!.bounds.size.width / 3.0, height: self.collectionView!.bounds.size.height)
        }
        return CGSize(width: self.collectionView!.bounds.size.height - 1.0, height: self.collectionView!.bounds.size.height - 1.0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        performSegueWithIdentifier("ShowClock", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {

        if segue.identifier == "ShowCities"
        {
            if segue.destinationViewController is UINavigationController
            {
                if let navController:UINavigationController = segue.destinationViewController as? UINavigationController
                {
                    if navController.viewControllers[0] is CityTableViewController
                    {
                        if let cityVC:CityTableViewController = navController.viewControllers[0] as? CityTableViewController
                        {
                            cityVC.delegate = self
                        }
                        
                    }
                }
            }
        }
        else if segue.identifier == "ShowClock"
        {
            if let clockCollectionViewCell = sender as? ClockCollectionViewCell
            {
                let indexPath = self.collectionView.indexPathForCell(clockCollectionViewCell)
                if let clockVC = segue.destinationViewController as? ClockViewController
                {
                    clockVC.timeZoneLocation = self.timeZoneArray[indexPath!.row]
                }
            }
            if let indexPath = sender as? NSIndexPath
            {
                if let clockVC = segue.destinationViewController as? ClockViewController
                {
                    clockVC.timeZoneLocation = self.timeZoneArray[indexPath.row]
                }
            }
        }
    }
    
    func updateClocks()
    {
        for var timeZone in self.timeZoneArray
        {
            timeZone.updateCurrentTime()
        }
        for indexPath in self.collectionView.indexPathsForVisibleItems()
        {
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? ClockCollectionViewCell
            cell?.isDay = self.timeZoneArray[indexPath.item].isDay
        }
    }
    
    func didSaveTimeZoneLocations(timeZoneLocations:[TimeZoneLocation])
    {
        self.timeZoneArray.appendContentsOf(timeZoneLocations)
        let timeZoneNSArray = NSArray(array: self.timeZoneArray.map({return $0.timeZoneName as NSString}))
        NSUserDefaults.standardUserDefaults().setObject(timeZoneNSArray, forKey: timeZoneKey)
        self.collectionView?.reloadData()
    }
    
    func redrawMap()
    {
        if self.lastMaskUpdate.timeIntervalSinceDate(NSDate()) < -60 * 10
        {
            self.sunsetPointArray = [CGPoint]()
            self.modelSunlightCurve()
        }
    }
    
    func createMask()
    {
        self.dayMapImageView.layer.mask = nil
        self.dayMapImageView.image = UIImage(named: "dayMap")
        let maskPath = UIBezierPath()
        let smallRadius:CGFloat = self.dayMapImageView.bounds.size.width * 0.0065
        let largeRadius:CGFloat = smallRadius * 5.25
        
        for index in 0..<self.sunsetPointArray.count
        {
            let coordinates = self.pointsDictionary["\(self.sunsetPointArray[index])"].string
            let coordinatesArr = coordinates!.characters.split{$0 == " "}.map(String.init)
            let point = CGPoint(x: Double(coordinatesArr[0])!, y: Double(coordinatesArr[1])!)
            //print(point)
            let pointLeft = CGPoint(x: 0.0, y: self.dayMapImageView.bounds.size.height * 0.5)
            let pointRight = CGPoint(x: self.dayMapImageView.bounds.size.width, y: self.dayMapImageView.bounds.size.height * 0.5)
            let pointTop = CGPoint(x: self.dayMapImageView.bounds.size.width * 0.5, y: 0.0)
            let pointBottom = CGPoint(x: self.dayMapImageView.bounds.size.width * 0.5, y: self.dayMapImageView.bounds.size.height)
            let minHypot = min(hypotf(Float(point.x - pointLeft.x), Float(point.y - pointLeft.y)),hypotf(Float(point.x - pointRight.x), Float(point.y - pointRight.y)),hypotf(Float(point.x - pointTop.x), Float(point.y - pointTop.y)),hypotf(Float(point.x - pointBottom.x), Float(point.y - pointBottom.y)))
            
            let radius = max((1 - CGFloat(minHypot) / (self.dayMapImageView.bounds.size.width * 0.5)) * largeRadius,smallRadius)
            let circleRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2.0, height: radius * 2.0)
            let circlePath = UIBezierPath(rect:circleRect)
            maskPath.appendPath(circlePath)
        }
        maskPath.closePath()
        dispatch_async(dispatch_get_main_queue(), {
            let shapeMask = CAShapeLayer()
            shapeMask.frame = self.dayMapImageView.bounds
            shapeMask.path = maskPath.CGPath
            self.dayMapImageView.layer.mask = shapeMask
            self.dayMapImageView.layer.mask?.setNeedsDisplay()
        
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
            
            let map = BGViewSnapShot.renderImageFromView(self.imageViewHolder)
            self.dayMapImageView.layer.mask = nil
            self.dayMapImageView.layer.setNeedsDisplay()
            self.dayMapImageView.image = map
            self.lastMaskUpdate = NSDate()
            
            
        })
        
    }
    
    func modelSunlightCurve()
    {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            calendar?.timeZone = NSTimeZone(name: "GMT")!
            let numberOfDaysInYear = calendar!.daysInYear()
            let dayOfYear = calendar?.ordinalityOfUnit(.Day, inUnit: .Year, forDate: NSDate())
            let numberOfSecondsInDay = 60 * 60 * 24
            
            let secondOfToday = calendar?.ordinalityOfUnit(.Second, inUnit: .Day, forDate: NSDate())
            
            let time = Double(secondOfToday!) / Double(numberOfSecondsInDay)
            
            var pointingFromEarthToSun = Vector3(x: -cos(Float(2.0 * M_PI) * Float(time)), y:0.0,z:sin(Float(2.0 * M_PI) * Float(time)))
            let tilt = 23.5 * cos(Float(2.0 * M_PI) * Float(dayOfYear! - 173)) / Float(numberOfDaysInYear!)
            
            let seasonOffset = Vector3(x:0.0,y:-tan(Float(M_PI * 2.0) * (tilt / 360.0)), z:0.0)
            
            pointingFromEarthToSun = pointingFromEarthToSun + seasonOffset
            
            pointingFromEarthToSun.normalized()
            var count = 0
            var u  = 90.0
            while u > -90.0 {
                var v = -180.0
                while v < 180.0 {
                    let phi  = Double(v) * M_PI / 180.0
                    let theta = Double(u) * M_PI / 180.0
                    let x = Float(cos(phi) * cos(theta))
                    let y = Float(cos(phi) * sin(theta))
                    let z = Float(sin(phi))
                    
                    let earthNormal = Vector3(x:x,y:y,z:z).normalized()
                    
                    let angleBetweenSurfaceAndSunlight = pointingFromEarthToSun.dot(earthNormal)
                    
                    if angleBetweenSurfaceAndSunlight > 0 && angleBetweenSurfaceAndSunlight < 0.10
                    {
                        let latLongPoint = CGPoint(x: u, y: v)
                        self.sunsetPointArray.append(latLongPoint)
                    }
                    else if angleBetweenSurfaceAndSunlight > 0 && angleBetweenSurfaceAndSunlight > 0.10
                    {
                        count += 1
                        if count > 1
                        {
                            let latLongPoint = CGPoint(x: u, y: v)
                            self.sunsetPointArray.append(latLongPoint)
                            count = 0
                        }
                    }
                    v += 1.0
                    
                }
                u -= 1.0
            }
            self.createMask()
            
        })
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension NSCalendar {
    func daysInYear(date: NSDate = NSDate()) -> Int? {
        let year = components([NSCalendarUnit.Year], fromDate: date).year
        return daysInYear(year)
    }
    
    func daysInYear(year: Int) -> Int? {
        guard let begin = lastDayOfYear(year - 1), end = lastDayOfYear(year) else { return nil }
        return components([NSCalendarUnit.Day], fromDate: begin, toDate: end, options: []).day
    }
    
    func lastDayOfYear(year: Int) -> NSDate? {
        let components = NSDateComponents()
        components.year = year
        guard let years = dateFromComponents(components) else { return nil }
        
        components.month = rangeOfUnit(NSCalendarUnit.Month, inUnit: NSCalendarUnit.Year, forDate: years).length
        guard let months = dateFromComponents(components) else { return nil }
        
        components.day = rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: months).length
        
        return dateFromComponents(components)
    }
}
