//
//  ValueTransformable.swift
//  Pods
//
//  Created by Sam Williams on 3/18/16.
//
//

import Foundation

public protocol ValueTransformable {
    static var valueTransformer: ValueTransformer<Self> { get }
}

/**
 A field whose value type conforms to ValueTransformable, automatically using the type's valueTransformer.
 
 I would rather make an extension `Field<T where T: ValueTransformable>` and have this work without using a different field subclass,
 but then the extension's overriding method won't be called by other methods in the base class.
 */

public class AutomaticField<T where T:ValueTransformable, T:Equatable>: Field<T> {
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }

    public override func defaultValueTransformer() -> ValueTransformer<T> {
        return T.valueTransformer
    }

}