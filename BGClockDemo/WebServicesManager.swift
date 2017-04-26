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
    var timer:Timer?
    
    var tempString:String?
    var weatherIconString:String?
    var stockQuoteString:NSString?
    var isDay:Bool?
    
    override init(){
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(WebServiceManager.didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
        let weatherFetchQ = DispatchQueue(label: "weather fetcher", attributes: [])
        weatherFetchQ.async(execute: {
            let weatherData = try? Data(contentsOf: URL(string: self.kWUndergroundConditionURLString)!)
            let json:[String:AnyObject] = try! JSONSerialization.jsonObject(with: weatherData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String : AnyObject]
            DispatchQueue.main.async(execute: {
                if let weatherDict:AnyObject = json["current_observation"]{
                    self.tempString = "\(weatherDict["feelslike_f"])℉"
                    self.weatherIconString = self.weatherIconForWeatherCondition(String(describing: weatherDict["weather"]))
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateWeatherNotification), object: nil)
                }
                
            })
        })
    }
    
    func fetchWeatherAndAstronomyForTimeZoneLocation(_ timeZoneLocal:TimeZoneLocation,mainThreadCompletionBlock:MainThreadCompletionBlock?)
    {
        var timeZoneLocation:TimeZoneLocation = TimeZoneLocation(timeZoneName: timeZoneLocal.timeZoneName, latitude: timeZoneLocal.latitude, longitude: timeZoneLocal.longitude, displayName: timeZoneLocal.displayName)
        let weatherFetchQ = DispatchQueue(label: "weather fetcher", attributes: [])
        weatherFetchQ.async(execute: {
            let weatherData = try? Data(contentsOf: URL(string: self.kWUndergroundConditionURLString + timeZoneLocation.latitude + "," + timeZoneLocation.longitude + ".json")!)
            if weatherData != nil {
                let json = try! JSON(data: weatherData!)
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
                var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                calendar.timeZone = TimeZone(identifier: timeZoneLocation.timeZoneName)!
                let dateComponents = (calendar as NSCalendar).components([.hour,.minute], from: Date())
                
                timeZoneLocation.currentHour = dateComponents.hour
                timeZoneLocation.currentMinute = dateComponents.minute
                
                DispatchQueue.main.async(execute: {
                    if mainThreadCompletionBlock != nil
                    {
                        mainThreadCompletionBlock!(true,timeZoneLocation)
                    }
                    
                })
            }else{
                DispatchQueue.main.async(execute: {
                    if mainThreadCompletionBlock != nil
                    {
                        mainThreadCompletionBlock!(false,timeZoneLocation)
                    }
                    
                })
            }

        })
    }
    
    func weatherIconForWeatherCondition(_ weatherCondition:String) -> String
    {
        if (self.isDay!)
        {
            if (weatherCondition.range(of: "Drizzle") != nil || weatherCondition.range(of: "Spray") != nil) {
                return "";
            }else if (weatherCondition.range(of: "Rain") != nil)
            {
                return "";
            }else if(weatherCondition.range(of: "Snow") != nil){
                return "";
            }else if(weatherCondition.range(of: "Ice") != nil || weatherCondition.range(of: "Hail") != nil){
                return "";
            }else if(weatherCondition.range(of: "Clear") != nil){
                return "";
            }else if(weatherCondition.range(of: "Partly Cloudy") != nil || weatherCondition.range(of: "Scattered Clouds") != nil){
                return "";
            }else if(weatherCondition.range(of: "Overcast") != nil){
                return "";
            }else if(weatherCondition.range(of: "Mist") != nil || weatherCondition.range(of: "Fog") != nil){
                return "";
            }else if (weatherCondition.range(of: "Haze") != nil){
                return "";
            }else if (weatherCondition.range(of: "Sand") != nil){
                return "";
            }else if (weatherCondition.range(of: "Rain Showers") != nil){
                return "";
            }else if (weatherCondition.range(of: "Thunderstorm") != nil){
                return "";
            }else if (weatherCondition.range(of: "Mostly Cloudy") != nil){
                return "";
            }else if (weatherCondition.range(of: "Funnel Cloud") != nil){
                return "";
            }
        }else{
            if (weatherCondition.range(of: "Drizzle") != nil || weatherCondition.range(of: "Spray") != nil) {
                return "";
            }else if (weatherCondition.range(of: "Rain") != nil)
            {
                return "";
            }else if(weatherCondition.range(of: "Snow") != nil){
                return "";
            }else if(weatherCondition.range(of: "Ice") != nil || weatherCondition.range(of: "Hail") != nil){
                return "";
            }else if(weatherCondition.range(of: "Clear") != nil){
                return "";
            }else if(weatherCondition.range(of: "Snow") != nil){
                return "";
            }else if(weatherCondition.range(of: "Partly Cloudy") != nil || weatherCondition.range(of: "Scattered Clouds") != nil){
                return "";
            }else if(weatherCondition.range(of: "Overcast") != nil){
                return "";
            }else if(weatherCondition.range(of: "Mist") != nil || weatherCondition.range(of: "Fog") != nil){
                return "";
            }else if (weatherCondition.range(of: "Haze") != nil){
                return "";
            }else if (weatherCondition.range(of: "Sand") != nil){
                return "";
            }else if (weatherCondition.range(of: "Rain Showers") != nil){
                return "";
            }else if (weatherCondition.range(of: "Thunderstorm") != nil){
                return "";
            }else if (weatherCondition.range(of: "Mostly Cloudy") != nil){
                return "";
            }else if (weatherCondition.range(of: "Funnel Cloud") != nil){
                return "";
            }
        }
        return "";
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

