//
//  EnumField.swift
//  Pods
//
//  Created by Sam Williams on 12/10/15.
//
//

import Foundation



/**
 A value transformer that attempts to convert between raw values and enums.
 */
open class EnumValueTransformer<E:RawRepresentable>: ValueTransformer<E> {
    
    public required init() {
        super.init()
    }
    
    open override func importValue(_ value:AnyObject?) -> E? {
        if let raw = value as? E.RawValue {
            return E(rawValue: raw)
        } else {
            return nil
        }
    }
    
    open override func exportValue(_ value:E?, explicitNull: Bool = false) -> AnyObject? {
        return (value?.rawValue as AnyObject?) ?? type(of: self).nullValue(explicit: explicitNull)
    }
}

/**
 A field whose value is a RawRepresentable
 */
open class EnumField<T>: Field<T> where T:RawRepresentable, T:Equatable {
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }
    
    open override func defaultValueTransformer() -> ValueTransformer<T> {
        return EnumValueTransformer<T>()
    }
}
