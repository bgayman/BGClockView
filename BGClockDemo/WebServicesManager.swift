//
//  WebServicesManager.swift
//  Apple Watch
//
//  Created by Brad G. on 3/3/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit

public let kUpdateWeatherNotification = "weatherupdate"

typealias MainThreadCompletionBlock = (Bool,TimeZoneLocation)->()

class WebServiceManager: NSObject {
    let kWUndergroundAPIKey = ""
    
    var kWUndergroundConditionURLString:String{
        return "http://api.wunderground.com/api/" + kWUndergroundAPIKey + "/conditions/astronomy/q/"
    }
    
    let kYahooStockQuoteURLString = "http://finance.yahoo.com/webservice/v1/symbols/AAPL/quote?format=json"
    var timer:NSTimer?
    
    var tempString:String?
    var weatherIconString:String?
    var stockQuoteString:NSString?
    var isDay:Bool?
    
    override init(){
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebServiceManager.didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func didBecomeActive()
    {
        self.timer?.invalidate()
        self.startUpdatingWebServices()
    }
    
    func startUpdatingWebServices()
    {
    }
    
    func fetchWeather()
    {
        let weatherFetchQ = dispatch_queue_create("weather fetcher", nil)
        dispatch_async(weatherFetchQ, {
            let weatherData = NSData(contentsOfURL: NSURL(string: self.kWUndergroundConditionURLString)!)
            let json:[String:AnyObject] = try! NSJSONSerialization.JSONObjectWithData(weatherData!, options: NSJSONReadingOptions.MutableContainers) as! [String : AnyObject]
            dispatch_async(dispatch_get_main_queue(), {
                if let weatherDict:AnyObject = json["current_observation"]{
                    self.tempString = "\(weatherDict["feelslike_f"])℉"
                    self.weatherIconString = self.weatherIconForWeatherCondition(String(weatherDict["weather"]))
                    NSNotificationCenter.defaultCenter().postNotificationName(kUpdateWeatherNotification, object: nil)
                }
                
            })
        })
    }
    
    func fetchWeatherAndAstronomyForTimeZoneLocation(timeZoneLocal:TimeZoneLocation,mainThreadCompletionBlock:MainThreadCompletionBlock?)
    {
        var timeZoneLocation:TimeZoneLocation = TimeZoneLocation(timeZoneName: timeZoneLocal.timeZoneName, latitude: timeZoneLocal.latitude, longitude: timeZoneLocal.longitude, displayName: timeZoneLocal.displayName)
        let weatherFetchQ = dispatch_queue_create("weather fetcher", nil)
        dispatch_async(weatherFetchQ, {
            let weatherData = NSData(contentsOfURL: NSURL(string: self.kWUndergroundConditionURLString + timeZoneLocation.latitude + "," + timeZoneLocation.longitude + ".json")!)
            if weatherData != nil {
                let json = JSON(data: weatherData!)
                if let sunsetHour = json["sun_phase"]["sunset"]["hour"].string{
                    timeZoneLocation.sunsetHour = Int(sunsetHour)
                }
                if let sunsetMinute = json["sun_phase"]["sunset"]["minute"].string{
                    timeZoneLocation.sunsetMinute = Int(sunsetMinute)
                }
                if let sunriseHour = json["sun_phase"]["sunrise"]["hour"].string{
                    timeZoneLocation.sunriseHour = Int(sunriseHour)
                }
                if let sunriseMinute = json["sun_phase"]["sunrise"]["minute"].string{
                    timeZoneLocation.sunriseMinute = Int(sunriseMinute)
                }
                if let feelsLike = json["current_observation"]["feelslike_f"].string{
                    timeZoneLocation.tempString = feelsLike + "℉"
                }
                if let weatherString = json["current_observation"]["weather"].string{
                    timeZoneLocation.weatherCondition = weatherString
                }
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                calendar?.timeZone = NSTimeZone(name: timeZoneLocation.timeZoneName)!
                let dateComponents = calendar!.components([.Hour,.Minute], fromDate: NSDate())
                
                timeZoneLocation.currentHour = dateComponents.hour
                timeZoneLocation.currentMinute = dateComponents.minute
                
                dispatch_async(dispatch_get_main_queue(), {
                    if mainThreadCompletionBlock != nil
                    {
                        mainThreadCompletionBlock!(true,timeZoneLocation)
                    }
                    
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    if mainThreadCompletionBlock != nil
                    {
                        mainThreadCompletionBlock!(false,timeZoneLocation)
                    }
                    
                })
            }

        })
    }
    
    func weatherIconForWeatherCondition(weatherCondition:String) -> String
    {
        if (self.isDay!)
        {
            if (weatherCondition.rangeOfString("Drizzle") != nil || weatherCondition.rangeOfString("Spray") != nil) {
                return "";
            }else if (weatherCondition.rangeOfString("Rain") != nil)
            {
                return "";
            }else if(weatherCondition.rangeOfString("Snow") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Ice") != nil || weatherCondition.rangeOfString("Hail") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Clear") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Partly Cloudy") != nil || weatherCondition.rangeOfString("Scattered Clouds") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Overcast") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Mist") != nil || weatherCondition.rangeOfString("Fog") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Haze") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Sand") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Rain Showers") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Thunderstorm") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Mostly Cloudy") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Funnel Cloud") != nil){
                return "";
            }
        }else{
            if (weatherCondition.rangeOfString("Drizzle") != nil || weatherCondition.rangeOfString("Spray") != nil) {
                return "";
            }else if (weatherCondition.rangeOfString("Rain") != nil)
            {
                return "";
            }else if(weatherCondition.rangeOfString("Snow") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Ice") != nil || weatherCondition.rangeOfString("Hail") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Clear") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Snow") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Partly Cloudy") != nil || weatherCondition.rangeOfString("Scattered Clouds") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Overcast") != nil){
                return "";
            }else if(weatherCondition.rangeOfString("Mist") != nil || weatherCondition.rangeOfString("Fog") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Haze") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Sand") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Rain Showers") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Thunderstorm") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Mostly Cloudy") != nil){
                return "";
            }else if (weatherCondition.rangeOfString("Funnel Cloud") != nil){
                return "";
            }
        }
        return "";
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

