//
//  AtomicAsyncTask.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct AtomicTask<Value>: Task {
    
    public let task: (Value) -> Void
    
    public init(_ task: @escaping (Value) -> Void) {
        self.task = { value in
            DispatchQueue.barrier.async(group: nil, qos: .background, flags: .barrier) {
                task(value)
            }
        }
    }
    
    public func run(_ value: Value) {
        self.task(value)
    }
}
