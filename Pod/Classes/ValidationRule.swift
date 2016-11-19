//
//  ValidationRule.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

open class ValidationRule<ValueType> {
    var test:((ValueType) -> Bool)?
    var message:String?
    var allowNil:Bool = true
    
    public init() { }
    
    public init(test:@escaping ((ValueType) -> Bool), message:String?=nil, allowNil:Bool = true) {
        self.message = message ?? "is invalid"
        self.test = test
        self.allowNil = allowNil
    }
    
    open func validate(_ value:ValueType?) -> Bool {
        if let unwrappedValue = value {
            return self.validate(unwrappedValue)
        } else {
            return self.allowNil
        }
    }
    
    func validate(_ value:ValueType) -> Bool {
        if let test = self.test {
            return test(value)
        } else {
            return true
        }
    }
}

open class RangeRule<T:Comparable>: ValidationRule<T> {
    var minimum:T?
    var maximum:T?

    public init(minimum:T?=nil, maximum:T?=nil) {
        super.init()
        self.minimum = minimum
        self.maximum = maximum
    }

    override func validate(_ value: T) -> Bool {
        if let minimum = self.minimum {
            if value < minimum {
                self.message = "must be greater than \(minimum)"
                return false
            }
        }
        if let maximum = self.maximum {
            if value > maximum {
                self.message = "must be less than \(maximum)"
                return false
            }
        }
        return true
    }
}

open class TransformerRule<FromType, ToType>: ValidationRule<FromType> {
    var rule:ValidationRule<ToType>?
    var transform:((FromType) -> ToType?)?
    
    override init() {
        super.init()
    }

    override func validate(_ value: FromType) -> Bool {
        let transformed = self.transform?(value)
        if let rule = self.rule {
            return rule.validate(transformed)
        } else {
            // Is this the right default?
            return false
        }
    }
}

open class LengthRule: TransformerRule<String, Int> {
    public init(minimum:Int?=nil, maximum:Int?=nil) {
        super.init()
        self.transform = { $0.characters.count }
        self.rule = RangeRule(minimum: minimum, maximum: maximum)
    }
}

open class NotBlankRule: ValidationRule<String> {
    override public init() {
        super.init()
        self.message = "cannot be blank"
    }
    
    override open func validate(_ value: String?) -> Bool {
        if let v = value {
            return v.characters.count > 0
        } else {
            return false
        }
    }

}
