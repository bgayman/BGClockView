//
//  TimeZoneLocation.swift
//  Apple Watch
//
//  Created by Brad G. on 3/4/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
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
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: self.timeZoneName)!
        let dateComponents = (calendar as NSCalendar).components([.hour,.minute], from: Date())
        
        self.currentHour = dateComponents.hour
        self.currentMinute = dateComponents.minute
    }
    
    func weatherIconForWeatherCondition(_ weatherCondition:String) -> String
    {
        if (self.isDay)
        {
            if (weatherCondition.range(of: "Drizzle") != nil || weatherCondition.range(of: "Spray") != nil) {
                return "";
            }else if (weatherCondition.range(of: "Rain") != nil){
                return "";
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
            }else if (weatherCondition.range(of: "Rain") != nil){
                return "";
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
    
    func angleBetweenSurfaceAndSunlightForLat(_ latitude:Float,longitude:Float) -> Float
    {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "GMT")!
        let numberOfDaysInYear = calendar.daysInYear()
        let dayOfYear = (calendar as NSCalendar?)?.ordinality(of: .day, in: .year, for: Date())
        let numberOfSecondsInDay = 60 * 60 * 24
        
        let secondOfToday = (calendar as NSCalendar?)?.ordinality(of: .second, in: .day, for: Date())
        
        let time = Double(secondOfToday!) / Double(numberOfSecondsInDay)
        
        var pointingFromEarthToSun = Vector3(x: -cos(Float(2.0 * .pi) * Float(time)), y:0.0,z:sin(Float(2.0 * .pi) * Float(time)))
        let tilt = 23.5 * cos(Float(2.0 * .pi) * Float(dayOfYear! - 173)) / Float(numberOfDaysInYear!)
        
        let seasonOffset = Vector3(x:0.0,y:-tan(Float(.pi * 2.0) * (tilt / 360.0)), z:0.0)
        
        pointingFromEarthToSun = pointingFromEarthToSun + seasonOffset
        
        _ = pointingFromEarthToSun.normalized()
        
        let phi  = Double(longitude) * .pi / 180.0
        let theta = Double(latitude) * .pi / 180.0
        let x = Float(cos(phi) * cos(theta))
        let y = Float(cos(phi) * sin(theta))
        let z = Float(sin(phi))
        
        let earthNormal = Vector3(x:x,y:y,z:z).normalized()
        
        return pointingFromEarthToSun.dot(earthNormal)
    }
}
