//
//  AsyncTask.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct AsyncTask<Value> {
    
    private let task: (Value) -> Void
    
    public init(task: @escaping (Value) -> Void) {
        self.task = { value in
            DispatchQueue.background.async {
                task(value)
            }
        }
    }
    
    // MARK: - Apply
    
    public func run(_ value: Value) {
        task(value)
    }
    
    // MARK: - functor
       
    public func contractMap<B>(queue: DispatchQueue,
                               _ f: @escaping (B) -> Value) -> AsyncTask<B> {
       return AsyncTask<B> { b in
           self.task(f(b))
       }
    }
    
    // MARK: - Atomical
    
    public func atomic() -> AtomicTask<Value> {
        return AtomicTask<Value>(task: task)
    }
}
