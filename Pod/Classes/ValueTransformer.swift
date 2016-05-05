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
    
    
    public func importValue(value:AnyObject?) -> T? {
        return self.importAction?(value)
    }
    
    public func exportValue(value:T?) -> AnyObject? {
        return self.exportAction?(value)
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