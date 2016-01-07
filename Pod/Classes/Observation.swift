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
 
 Observations are themselves Observable, which means we can chain them:
    let a = Field<String>()
    let b = Field<String>()
    let c = Field<String>()
 
    a --> b --> c
 */
public class Observation<T>: Observable {
    public typealias ValueType = T
    
    public var observations = ObservationRegistry<T>()
    
    public var value:T? {
        get {
            return self.getValue?()
        }
        set {
            self.onChange?(newValue)
            self.notifyObservers()
        }
    }
    
    var onChange:(T? -> Void)?
    var getValue:(Void -> T?)?
    
    public func valueChanged(newValue:T?) {
        self.value = newValue
    }
}

/**
 A mapping of owner objects to Observations.  Owner references are weak.  Observation references are strong.
 */
public class ObservationRegistry<V> {
    var observations:NSMapTable = NSMapTable.weakToStrongObjectsMapTable()
    
    public init() { }

    func clear() {
        self.observations.removeAllObjects()
    }
    
    func each(closure:(Observation<V> -> Void)) {
        let enumerator = self.observations.objectEnumerator()
        
        while let observation = enumerator?.nextObject() {
            if let observation = observation as? Observation<V> {
                closure(observation)
            }
        }
    }
    
    func get<U:Observer where U.ValueType==V>(observer:U?) -> Observation<V>? {
        return self.observations.objectForKey(observer) as? Observation<V>
    }

    func setNil(observation:Observation<V>?) {
        self.observations.setObject(observation, forKey: DefaultObserverKey)
    }

    func set(owner:AnyObject, _ observation:Observation<V>?) {
        self.observations.setObject(observation, forKey: owner)
    }
    
    func remove<U:Observer where U.ValueType==V>(observer:U) {
        self.observations.removeObjectForKey(observer)
    }

}

