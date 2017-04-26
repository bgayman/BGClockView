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
    
    var lastMaskUpdate = Date()
    
    var sunsetPointArray = [CGPoint]()
    lazy var pointsDictionary:JSON = {
        let fileName = String(Int(self.view.bounds.size.width))
        let filePath = Bundle.main.path(forResource: fileName, ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        let json = try! JSON(data: data!)
        return json
    }()
    var timeZoneArray = [TimeZoneLocation]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBarController?.tabBar.tintColor = UIColor.black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.settingsButton.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "FontAwesome", size: 22.0)!], for: UIControlState())
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.redrawMap), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let timeZoneManager = appDelegate.timeZoneManager
        if let timeZoneNameArray = UserDefaults.standard.object(forKey: timeZoneKey) as? NSArray
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
        Timer.scheduledTimer(timeInterval: 60.0 * 2.0, target: self, selector: #selector(BGWorldClockViewController.updateClocks), userInfo: nil, repeats: true)
        self.modelSunlightCurve()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.redrawMap()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.black
        self.tabBarController?.tabBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timeZoneArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ClockCollectionViewCell
        
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
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        if self.collectionView!.bounds.size.width / 3.0 < self.collectionView.bounds.size.height
        {
            return CGSize(width: self.collectionView!.bounds.size.width / 3.0, height: self.collectionView!.bounds.size.height)
        }
        return CGSize(width: self.collectionView!.bounds.size.height - 1.0, height: self.collectionView!.bounds.size.height - 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "ShowClock", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {

        if segue.identifier == "ShowCities"
        {
            if segue.destination is UINavigationController
            {
                if let navController:UINavigationController = segue.destination as? UINavigationController
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
                let indexPath = self.collectionView.indexPath(for: clockCollectionViewCell)
                if let clockVC = segue.destination as? ClockViewController
                {
                    clockVC.timeZoneLocation = self.timeZoneArray[indexPath!.row]
                }
            }
            if let indexPath = sender as? IndexPath
            {
                if let clockVC = segue.destination as? ClockViewController
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
        for indexPath in self.collectionView.indexPathsForVisibleItems
        {
            let cell = self.collectionView.cellForItem(at: indexPath) as? ClockCollectionViewCell
            cell?.isDay = self.timeZoneArray[indexPath.item].isDay
        }
    }
    
    func didSaveTimeZoneLocations(_ timeZoneLocations:[TimeZoneLocation])
    {
        self.timeZoneArray.append(contentsOf: timeZoneLocations)
        let timeZoneNSArray = NSArray(array: self.timeZoneArray.map({return $0.timeZoneName as NSString}))
        UserDefaults.standard.set(timeZoneNSArray, forKey: timeZoneKey)
        self.collectionView?.reloadData()
    }
    
    func redrawMap()
    {
        if self.lastMaskUpdate.timeIntervalSince(Date()) < -60 * 10 && self.dayMapImageView.layer.mask != nil

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
        let largeRadius:CGFloat = smallRadius * 6.50
        
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
            maskPath.append(circlePath)
            self.view.bringSubview(toFront: self.dayMapImageView)
        }
        DispatchQueue.main.async(execute: {
            let shapeMask = CAShapeLayer()
            shapeMask.frame = self.dayMapImageView.bounds
            shapeMask.path = maskPath.cgPath
            self.dayMapImageView.layer.mask = shapeMask
            self.dayMapImageView.layer.mask?.setNeedsDisplay()
        
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            let map = BGViewSnapShot.renderImageFromView(self.imageViewHolder)
            self.dayMapImageView.layer.mask = nil
            self.dayMapImageView.layer.setNeedsDisplay()
            self.dayMapImageView.image = map
            self.lastMaskUpdate = Date()
            
            
        })
        
    }
    
    func modelSunlightCurve()
    {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        DispatchQueue.global(qos: .default).async(execute: {
            var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            calendar.timeZone = TimeZone(identifier: "GMT")!
            let numberOfDaysInYear = calendar.daysInYear()
            let dayOfYear = (calendar as NSCalendar?)?.ordinality(of: .day, in: .year, for: Date())
            let numberOfSecondsInDay = 60 * 60 * 24
            
            let secondOfToday = (calendar as NSCalendar?)?.ordinality(of: .second, in: .day, for: Date())
            
            let time = Double(secondOfToday!) / Double(numberOfSecondsInDay)
            
            var pointingFromEarthToSun = Vector3(x: -cos(Float(2.0 * Float.pi) * Float(time)), y:0.0,z:sin(Float(2.0 * .pi) * Float(time)))
            let tilt = 23.5 * cos(Float(2.0 * .pi) * Float(dayOfYear! - 173)) / Float(numberOfDaysInYear!)
            
            let seasonOffset = Vector3(x:0.0,y:-tan(Float(.pi * 2.0) * (tilt / 360.0)), z:0.0)
            
            pointingFromEarthToSun = pointingFromEarthToSun + seasonOffset
            
            _ = pointingFromEarthToSun.normalized()
            var count = 0
            var u  = 90.0
            while u > -90.0 {
                var v = -180.0
                while v < 180.0 {
                    let phi  = Double(v) * Double.pi / 180.0
                    let theta = Double(u) * .pi / 180.0
                    let x = Float(cos(phi) * cos(theta))
                    let y = Float(cos(phi) * sin(theta))
                    let z = Float(sin(phi))
                    
                    let earthNormal = Vector3(x:x,y:y,z:z).normalized()
                    
                    let angleBetweenSurfaceAndSunlight = pointingFromEarthToSun.dot(earthNormal)
                    
                    if angleBetweenSurfaceAndSunlight > 0 //&& angleBetweenSurfaceAndSunlight < 0.10
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
        NotificationCenter.default.removeObserver(self)
    }

}

extension Calendar {
    func daysInYear(_ date: Date = Date()) -> Int? {
        let year = dateComponents([.year], from: date).year
        return daysInYear(year!)
    }
    
    func daysInYear(_ year: Int) -> Int? {
        guard let begin = self.lastDayOfYear(year - 1),
              let end = self.lastDayOfYear(year)
        else { return nil }
        return self.dateComponents([.day], from: begin, to: end).day
    }
    
    func lastDayOfYear(_ year: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        guard let years = date(from: components) else { return nil }
        
        components.month = self.range(of: .month, in: .year, for: years)?.count
        guard let months = date(from: components) else { return nil }
        
        components.day = range(of: .day, in: .month, for: months)?.count
        
        return date(from: components)
    }
}
