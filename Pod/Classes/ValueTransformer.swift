//
//  FieldSerializer.swift
//  Pods
//
//  Created by Sam Williams on 12/7/15.
//
//

import Foundation

public protocol ValueTransformerType {
}

/**
 A strongly typed transformer between AnyObject and a particular type.
 The default implementation does nothing (i.e., everything is mapped to nil).
 */
public class ValueTransformer<T>: ValueTransformerType {
    public typealias ImportActionType = (AnyObject? -> T?)
    public typealias ExportActionType = (T? -> AnyObject?)
    
    var importAction: ImportActionType?
    var exportAction: ExportActionType?
    
    public required init() {
        
    }
    
    public init(importAction:ImportActionType, exportAction:ExportActionType) {
        self.importAction = importAction
        self.exportAction = exportAction
    }
    
    /**
     Attempts to convert an external value to an internal form.  If that's not possible, or if the external value is nil, returns nil.
     */
    public func importValue(value:AnyObject?) -> T? {
        return self.importAction?(value)
    }

    /**
     Transforms a value into an external form suitable for serialization.
     - parameter explicitNull: If false, export nil values as nil. If true, export nil values as a special null value (defaulting to NSNull)
     */
    public func exportValue(value:T?, explicitNull: Bool = false) -> AnyObject? {
        if let value = self.exportAction?(value) {
            return value
        } else {
            return self.dynamicType.nullValue(explicit: explicitNull)
        }
    }
    
    /**
     Generates an external value representing nil.
     - parameter explicit: Whether the value should be a special (non-nil) value.
     */
    public class func nullValue(explicit explicit: Bool = false) -> AnyObject? {
        return explicit ? NSNull() : nil
    }
    
    /**
     Determine whether an external value represents nil.  By default, this will be true for `nil` and `NSNull` instances.
     */
    public class func valueIsNull(value: AnyObject?) -> Bool {
        return value == nil || value is NSNull
    }
}

/**
 The simplest working implementation of a transformer: just attempts to cast between T and AnyObject
 */
public class SimpleValueTransformer<T>: ValueTransformer<T> {
    
    public required init() {
        super.init(importAction: { $0 as? T }, exportAction: { $0 as? AnyObject } )
    }
}