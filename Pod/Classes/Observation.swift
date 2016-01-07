//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public class Observation<T> {
    var onChange:(T? -> Void)?
    var getValue:(Void -> T?)?
}

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

