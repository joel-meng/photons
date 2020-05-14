//
//  ImmediateTask.swift
//  photons
//
//  Created by Jun Meng on 14/5/20.
//

import Foundation

public struct ImmediateTask<Value>: Task {
    
    public private(set) var task: (Value) -> Void
    
    public init(_ task: @escaping (Value) -> Void) {
        self.task = task
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
