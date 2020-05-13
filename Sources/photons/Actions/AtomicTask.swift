//
//  AtomicAsyncTask.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct AtomicTask<Value> {
    
    private let task: (Value) -> Void
    
    init(task: @escaping (Value) -> Void) {
        self.task = { value in
            DispatchQueue.barrier.async(group: nil, qos: .background, flags: .barrier) {
                task(value)
            }
        }
    }
}
