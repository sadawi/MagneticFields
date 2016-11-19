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

open class AutomaticField<T>: Field<T> where T:ValueTransformable, T:Equatable {
    public override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }

    open override func defaultValueTransformer() -> ValueTransformer<T> {
        return T.valueTransformer
    }

}
