//
//  DateTransformer.swift
//  Pods
//
//  Created by Sam Williams on 2/16/16.
//
//

import Foundation

open class DateTransformer: ValueTransformer<Date> {
    open var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.locale = Locale(identifier: "en_US_POSIX")
        result.timeZone = TimeZone.autoupdatingCurrent
        return result
    }()
    
    public required init() {
        super.init()
    }
    
    public convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateFormatter = dateFormatter
    }

    public convenience init(dateFormat: String, locale: Locale? = nil, timeZone: TimeZone? = nil) {
        self.init()
        self.dateFormatter.dateFormat = dateFormat
        if let locale = locale {
            self.dateFormatter.locale = locale
        }
        if let timeZone = timeZone {
            self.dateFormatter.timeZone = timeZone
        }
    }
    
    override open func importValue(_ value:AnyObject?) -> Date? {
        if let value = value as? String {
            return self.dateFormatter.date(from: value)
        } else {
            return nil
        }
    }
    
    override open func exportValue(_ value:Date?, explicitNull: Bool = false) -> AnyObject? {
        if let value = value {
            return self.dateFormatter.string(from: value) as AnyObject?
        } else {
            return type(of: self).nullValue(explicit: explicitNull)
        }
    }
}
