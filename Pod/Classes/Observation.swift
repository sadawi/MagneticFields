//
//  Observation.swift
//  Pods
//
//  Created by Sam Williams on 11/28/15.
//
//

import Foundation

public typealias ObservationKey = Int

public class Observation<T> {
    public typealias ObservationAction = (T? -> Void)
    
    var action:ObservationAction?
   
    public init(action:ObservationAction?) {
        self.action = action
    }
    
    public func call<ObservableType:Observable where ObservableType.ValueType == T>(value value:T?, observable:ObservableType?) {
        self.action?(observable?.value)
    }
}

public class ObservationRegistry<V> {
    var observations:[ObservationKey:Observation<V>] = [:]
    
    public init() { }

    class func keyForObject(object:AnyObject?) -> ObservationKey {
        return ObjectIdentifier(object ?? DefaultObserverKey).hashValue
    }
    
    func clear() {
        self.observations = [:]
    }
    
    func each(closure:(Observation<V> -> Void)) {
        for (_, observation) in self.observations {
            closure(observation)
        }
    }
    
    func get<U:Observer where U.ValueType==V>(observer:U?) -> Observation<V>? {
        return self.observations[ObservationRegistry.keyForObject(observer)]
    }

    func setNil(observation:Observation<V>?) {
        self.observations[ObservationRegistry.keyForObject(nil)] = observation
    }

    func set<U:Observer where U.ValueType==V>(observer:U?, _ observation:Observation<V>?) {
        self.observations[ObservationRegistry.keyForObject(observer)] = observation
    }
    
    func remove<U:Observer where U.ValueType==V>(observer:U) {
        self.set(observer, nil)
    }

}

