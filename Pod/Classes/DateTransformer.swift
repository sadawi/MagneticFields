//
//  DateTransformer.swift
//  Pods
//
//  Created by Sam Williams on 2/16/16.
//
//

import Foundation

public class DateTransformer: ValueTransformer<NSDate> {
    public var dateFormatter: NSDateFormatter = {
        let result = NSDateFormatter()
        result.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        result.timeZone = NSTimeZone.localTimeZone()
        return result
    }()
    
    public required init() {
        super.init()
    }
    
    public convenience init(dateFormatter: NSDateFormatter) {
        self.init()
        self.dateFormatter = dateFormatter
    }

    public convenience init(dateFormat: String, locale: NSLocale? = nil, timeZone: NSTimeZone? = nil) {
        self.init()
        self.dateFormatter.dateFormat = dateFormat
        if let locale = locale {
            self.dateFormatter.locale = locale
        }
        if let timeZone = timeZone {
            self.dateFormatter.timeZone = timeZone
        }
    }
    
    override public func importValue(value:AnyObject?) -> NSDate? {
        if let value = value as? String {
            return self.dateFormatter.dateFromString(value)
        } else {
            return nil
        }
    }
    
    override public func exportValue(value:NSDate?, explicitNull: Bool = false) -> AnyObject? {
        if let value = value {
            return self.dateFormatter.stringFromDate(value)
        } else {
            return self.dynamicType.nullValue(explicit: explicitNull)
        }
    }
}
