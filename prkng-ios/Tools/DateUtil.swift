//
//  DateUtil.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 01/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class DateUtil {
   
    class func dayIndexOfTheWeek() -> Int {
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar?.components(.WeekdayCalendarUnit, fromDate: todayDate)
        let weekDay = myComponents?.weekday
        
        if (weekDay == 1) {
            return 6
        }
        
        return (weekDay! - 2)
    }
    
    
    class func hourFloatRepresentation () -> Float {   // Example : 10:30 -> 10.5
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        
        return Float(hour % 12) + (Float(minutes) / 60.0)
    
    }
    
}
