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
public class EnumValueTransformer<E:RawRepresentable>: ValueTransformer<E> {
    
    public override init() {
        super.init()
    }
    
    public override func importValue(value:AnyObject?) -> E? {
        if let raw = value as? E.RawValue {
            return E(rawValue: raw)
        } else {
            return nil
        }
    }
    
    public override func exportValue(value:E?) -> AnyObject? {
        return value?.rawValue as? AnyObject
    }
}

/**
 A field whose value is a RawRepresentable
 */
public class EnumField<T where T:RawRepresentable, T:Equatable>: Field<T> {
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }
    
    public override func defaultValueTransformer() -> ValueTransformer<T> {
        return EnumValueTransformer<T>()
    }
}