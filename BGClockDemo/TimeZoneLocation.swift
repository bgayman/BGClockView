//
//  TimeZoneLocation.swift
//  Apple Watch
//
//  Created by Brad G. on 3/4/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation

struct TimeZoneLocation
{
    let timeZoneName:String
    let latitude:String
    let longitude:String
    let displayName:String
    
    var tempString:String?
    var weatherCondition:String?
    var weatherIconString:String?{
        get{
            if self.weatherCondition != nil {
                return self.weatherIconForWeatherCondition(self.weatherCondition!)
            }
            return nil
        }
    }
    
    var sunriseHour:Int?
    var sunriseMinute:Int?
    var sunsetHour:Int?
    var sunsetMinute:Int?
    
    var currentHour:Int?
    var currentMinute:Int?
    
    var isDay:Bool{
        get{
            if currentHour != nil && currentMinute != nil && sunsetHour != nil && sunriseHour != nil {
                if currentHour > sunsetHour || (currentHour == sunsetHour && currentMinute > sunsetMinute)
                {
                    return false
                }
                if currentHour < sunriseHour || (currentHour == sunriseHour && currentMinute < sunriseMinute)
                {
                    return false
                }
                return true
            }
            else
            {
                if self.angleBetweenSurfaceAndSunlightForLat(Float(self.latitude)!, longitude: Float(self.longitude)!) > 0 {
                    return true
                }
                return false
            }
            
        }
    }
    
    init (timeZoneName:String,latitude:String,longitude:String,displayName:String){
        self.timeZoneName = timeZoneName
        self.latitude = latitude
        self.longitude = longitude
        self.displayName = displayName
    }
    
    mutating func updateCurrentTime()
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.timeZone = NSTimeZone(name: self.timeZoneName)!
        let dateComponents = calendar!.components([.Hour,.Minute], fromDate: NSDate())
        
        self.currentHour = dateComponents.hour
        self.currentMinute = dateComponents.minute
    }
    
    func weatherIconForWeatherCondition(weatherCondition:String) -> String
    {
        if (self.isDay)
        {
            if (weatherCondition.rangeOfString("Drizzle") != nil || weatherCondition.rangeOfString("Spray") != nil) {
                return "";
            }else if (weatherCondition.rangeOfString("Rain") != nil){
                return "";
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
            }else if (weatherCondition.rangeOfString("Rain") != nil){
                return "";
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
    
    func angleBetweenSurfaceAndSunlightForLat(latitude:Float,longitude:Float) -> Float
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
        
        let phi  = Double(longitude) * M_PI / 180.0
        let theta = Double(latitude) * M_PI / 180.0
        let x = Float(cos(phi) * cos(theta))
        let y = Float(cos(phi) * sin(theta))
        let z = Float(sin(phi))
        
        let earthNormal = Vector3(x:x,y:y,z:z).normalized()
        
        return pointingFromEarthToSun.dot(earthNormal)
    }
}