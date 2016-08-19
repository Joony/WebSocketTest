//
//  Signal.swift
//  InSilicoInternal
//
//  Created by Jonathan McAllister on 18/05/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import Foundation

public final class Signal<T> {
    
    var event: Result<T>?
    var callbacks: [Result<T> -> Void] = []
    
    init() {
        
    }
    
    init(value: T) {
        self.event = Result.Success(value)
    }
    
    init(event: Result<T>) {
        self.event = event
    }
    
    func notify() {
        guard let event = self.event else {
            return
        }
        
        self.callbacks.forEach { callback in
            callback(event)
        }
    }
    
    func publish(event event: Result<T>) {
        self.event = event
        
        self.notify()
    }
    
    func publish(event event: T) {
        self.event = lift(event)
        
        self.notify()
    }
    
    public func subscribe(f: Result<T> -> Void) -> Signal<T> {
        if let event = self.event {
            f(event)
        }
        
        self.callbacks.append(f)
        
        return self
    }
    
    public func map<U>(f: T -> U) -> Signal<U> {
        let signal = Signal<U>()
        
        self.subscribe { event in
            signal.publish(event: event.map(f))
        }
        
        return signal
    }
    
    func flatMap<U>(f: T -> Result<U>) -> Signal<U> {
        let signal = Signal<U>()
        
        self.subscribe { event in
            signal.publish(event: event.flatMap(f))
        }
        
        return signal
    }
    
}
