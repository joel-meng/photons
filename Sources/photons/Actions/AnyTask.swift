//
//  AnyTask.swift
//  photons
//
//  Created by Jun Meng on 14/5/20.
//

import Foundation

struct AnyTask<Value>: Task {
    
    var task: (Value) -> Void
    
    init(_ task: @escaping (Value) -> Void) {
        self.task = task
    }
    
    init<T: Task>(task: T) where T.Value == Value {
        self.task = task.task
    }
    
    func run(_ value: Value) {
        task(value)
    }
    
    typealias Value = Value
}
