//
//  TimeZoneManager.swift
//  Apple Watch
//
//  Created by Brad G. on 3/4/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation

struct TimeZoneManager
{
    var allTimeZones:[TimeZoneLocation]
    var timeZoneDictionary:[String:[TimeZoneLocation]]
    init()
    {
        allTimeZones = [TimeZoneLocation]()
        timeZoneDictionary = [String:[TimeZoneLocation]]()
        self.allTimeZones = self.getAllTimeZones()
    }
    
    mutating func getAllTimeZones() -> [TimeZoneLocation]
    {
        var timeZones = [TimeZoneLocation]()
        let path = NSBundle.mainBundle().pathForResource("Coordinates", ofType: "txt")//or rtf for an rtf file
        let coordinatesString = try! String(contentsOfFile: path!)
        let csv = CSwiftV(String: coordinatesString)
        let csvRows = csv.rows
        for index in 0...NSTimeZone.knownTimeZoneNames().count - 1
        {
            let timeZoneRow = csvRows[index]
            let timeZoneName:NSString = NSTimeZone.knownTimeZoneNames()[index]
            if timeZoneRow.count == 3
            {
                var displayName = timeZoneRow[0] as NSString
                displayName = displayName.stringByReplacingOccurrencesOfString(",", withString: "")
                let timeZoneLocation = TimeZoneLocation(timeZoneName:timeZoneName as String,latitude:timeZoneRow[1],longitude:timeZoneRow[2],displayName:displayName as String)
                timeZones.append(timeZoneLocation)
                
                let pathComponents = timeZoneName.pathComponents
                if let firstPathComponent = pathComponents.first
                {
                    if self.timeZoneDictionary[firstPathComponent] != nil
                    {
                        self.timeZoneDictionary[firstPathComponent]!.append(timeZoneLocation)
                    }
                    else
                    {
                        self.timeZoneDictionary[firstPathComponent] = [timeZoneLocation]
                    }
                }

            }
            
        }
        return timeZones
    }
    
    func timeZoneLocationForTimeZoneName(timeZoneName:String) -> TimeZoneLocation?
    {
        if let i = self.allTimeZones.indexOf({$0.timeZoneName == timeZoneName}) {
            return self.allTimeZones[i]
        }
        return nil
    }
}