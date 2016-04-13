//
//  BGWorldClockViewController.swift
//  BGClockDemo
//
//  Created by Brad G. on 3/11/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let timeZoneKey = "TimeZones"

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

class BGWorldClockViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,CityTableDelegate,UIWebViewDelegate {
    
    @IBOutlet weak var webViewHolder: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    var webView: UIWebView?
    var webView2: UIWebView?
    var sunsetPointArray = [CGPoint]()
    var timeZoneArray = [TimeZoneLocation]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        self.settingsButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "FontAwesome", size: 22.0)!], forState: .Normal)
        
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
        
        self.modelSunlightCurve()
        NSTimer.scheduledTimerWithTimeInterval(60.0 * 2.0, target: self, selector: #selector(BGWorldClockViewController.updateClocks), userInfo: nil, repeats: true)
        
        self.webView2 = UIWebView(frame: self.webViewHolder.bounds)
        self.webView2?.scrollView.scrollEnabled = false
        self.webViewHolder.addSubview(self.webView2!)
        self.webView = UIWebView(frame: self.webViewHolder.bounds)
        self.webView?.scrollView.scrollEnabled = false
        self.webViewHolder.addSubview(self.webView!)
        self.webView2?.translatesAutoresizingMaskIntoConstraints = false
        self.webViewHolder.addConstraints(self.constraintsForWebView(self.webView2!))
        let url2 = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("map2", ofType:"html")!)
        self.webView2?.loadRequest(NSURLRequest(URL: url2))
        
        self.webView?.translatesAutoresizingMaskIntoConstraints = false
        self.webViewHolder.addConstraints(self.constraintsForWebView(self.webView!))
        let url = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("map", ofType:"html")!)
        self.webView?.delegate = self
        self.webView?.loadRequest(NSURLRequest(URL: url))
        
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.tabBarController?.tabBar.barTintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor = UIColor.blackColor()
        self.tabBarController?.tabBar.translucent = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
    }
    
    func constraintsForWebView(webV:UIWebView) -> [NSLayoutConstraint]
    {
        let leadingConstraint = NSLayoutConstraint(item: webV,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webViewHolder,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0)
        
        let trailingConstraint =
        NSLayoutConstraint(item: webV,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webViewHolder,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 0)
        
        let topConstraint =
        NSLayoutConstraint(item: webV,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webViewHolder,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0)
        
        let bottomConstraint =
        NSLayoutConstraint(item: webV,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webViewHolder,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        
        
        let constraints = [
            leadingConstraint,
            trailingConstraint,
            topConstraint,
            bottomConstraint
        ]
        
        return constraints
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

    func webViewDidFinishLoad(webView: UIWebView) {
        self.createMask()
        //self.addMapAnnotations()
    }
    
    func redrawMap()
    {
        self.modelSunlightCurve()
        self.createMask()
    }
    
    func createMask()
    {
        self.webView?.layer.mask = nil
        let maskPath = UIBezierPath()
        let smallRadius:CGFloat = self.webView!.bounds.size.width * 0.0065
        let largeRadius:CGFloat = smallRadius * 5.25
        
        for index in 0..<self.sunsetPointArray.count
        {
            let coordinates = self.webView?.stringByEvaluatingJavaScriptFromString("performProjection(\(self.sunsetPointArray[index].x),\(self.sunsetPointArray[index].y))")
            let coordinatesArr = coordinates!.characters.split{$0 == " "}.map(String.init)
            let point = CGPoint(x: Double(coordinatesArr[0])!, y: Double(coordinatesArr[1])!)
            
            let pointLeft = CGPoint(x: 0.0, y: self.webView!.bounds.size.height * 0.5)
            let pointRight = CGPoint(x: self.webView!.bounds.size.width, y: self.webView!.bounds.size.height * 0.5)
            let pointTop = CGPoint(x: self.webView!.bounds.size.width * 0.5, y: 0.0)
            let pointBottom = CGPoint(x: self.webView!.bounds.size.width * 0.5, y: self.webView!.bounds.size.height)
            let minHypot = min(hypotf(Float(point.x - pointLeft.x), Float(point.y - pointLeft.y)),hypotf(Float(point.x - pointRight.x), Float(point.y - pointRight.y)),hypotf(Float(point.x - pointTop.x), Float(point.y - pointTop.y)),hypotf(Float(point.x - pointBottom.x), Float(point.y - pointBottom.y)))
            
            let radius = max((1 - CGFloat(minHypot) / (self.webView!.bounds.size.width * 0.5)) * largeRadius,smallRadius)
            let circlePath = UIBezierPath(ovalInRect: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2.0, height: radius * 2.0))
            
            maskPath.appendPath(circlePath)
        }
        let shapeMask = CAShapeLayer()
        shapeMask.frame = (self.webView?.bounds)!
        shapeMask.path = maskPath.CGPath
        self.webView?.layer.mask = shapeMask
        self.webView?.layer.mask?.setNeedsDisplay()
    }
    
    func modelSunlightCurve()
    {
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
                
                if angleBetweenSurfaceAndSunlight > 0
                {
                    let latLongPoint = CGPoint(x: u, y: v)
                    self.sunsetPointArray.append(latLongPoint)
                }
                v += 1.50
                
            }
            u -= 1.50
        }
    }
    
    func addMapAnnotations()
    {
        for timeZoneLocation in self.timeZoneArray
        {
            let coordinates = self.webView?.stringByEvaluatingJavaScriptFromString("performProjection(\(timeZoneLocation.latitude),\(timeZoneLocation.longitude))")
            let coordinatesArr = coordinates!.characters.split{$0 == " "}.map(String.init)
            let point = CGPoint(x: Double(coordinatesArr[0])!, y: Double(coordinatesArr[1])!)
            let rect = self.view.convertRect(CGRect(x: point.x - 22.5, y: point.y - 20.0, width: 45.0, height: 40.0), fromView: self.webView)
            let annotationView = WorldClockMapAnnotationView(frame:rect)
            self.view.addSubview(annotationView)

            if timeZoneLocation.tempString != nil
            {
                
                annotationView.timeZoneLocation = timeZoneLocation
            }
            else
            {
    
                WebServiceManager().fetchWeatherAndAstronomyForTimeZoneLocation(timeZoneLocation, mainThreadCompletionBlock: {(success:Bool,tZL:TimeZoneLocation) in
                    if success
                    {
                        annotationView.timeZoneLocation = tZL
                    }
                })
            }

        }
    }

}
