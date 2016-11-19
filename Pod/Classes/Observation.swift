//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

/**
 An object that holds a closure that is to be run when a value changes.
 
 `Observation` instances are themselves `Observable`, which means they can be chained:
 ```
 let a = Field<String>()
 let b = Field<String>()
 let c = Field<String>()
 a --> b --> c
 ```
 */
open class Observation<T>: Observable {
    public typealias ValueType = T
    
    open var observations = ObservationRegistry<T>()
    
    open var value:T? {
        get {
            return self.getValue?()
        }
        set {
            self.onChange?(newValue)
            self.notifyObservers()
        }
    }
    
    var onChange:((T?) -> Void)?
    var getValue:((Void) -> T?)?
    
    open func valueChanged(_ newValue:T?) {
        self.value = newValue
    }
}

/**
 A mapping of owner objects to Observations.  Owner references are weak.  Observation references are strong.
 */
open class ObservationRegistry<V> {
    var observations:NSMapTable<AnyObject, Observation<V>> = NSMapTable.weakToStrongObjects()
    
    public init() { }

    func clear() {
        self.observations.removeAllObjects()
    }
    
    func each(_ closure:((Observation<V>) -> Void)) {
        let enumerator = self.observations.objectEnumerator()
        
        while let observation = enumerator?.nextObject() {
            if let observation = observation as? Observation<V> {
                closure(observation)
            }
        }
    }
    
    func get<U:Observer>(_ observer:U?) -> Observation<V>? where U.ValueType==V {
        return self.observations.object(forKey: observer)
    }

    func setNil(_ observation:Observation<V>?) {
        self.observations.setObject(observation, forKey: DefaultObserverKey)
    }

    func set(_ owner:AnyObject, _ observation:Observation<V>?) {
        self.observations.setObject(observation, forKey: owner)
    }
    
    func remove<U:Observer>(_ observer:U) where U.ValueType==V {
        self.observations.removeObject(forKey: observer)
    }

}

