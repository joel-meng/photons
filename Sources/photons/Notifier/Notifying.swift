//
//  Notifying.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct TaskBinding<Value> {
    
    var notify: (AsyncTask<Value>) -> ValueResolving<Value>
    
    public init(_ notify: @escaping (AsyncTask<Value>) -> ValueResolving<Value>) {
        self.notify = notify
    }
}

extension TaskBinding {
    
    static func pure() -> TaskBinding<Value> {
        return TaskBinding<Value> { (task) -> ValueResolving<Value> in
            let notifier = Notifier<Value>()
            notifier.addNotifier(task)
            
            return ValueResolving { value in
                notifier.broadcast(newValue: value)
            }
        }
    }
}

public struct AtomicNotifying<Value> {
    
    var notify: (AsyncTask<Value>) -> ValueResolving<Value>
    
    public init(_ notify: @escaping (AsyncTask<Value>) -> ValueResolving<Value>) {
        
        self.notify = { task in
            DispatchQueue.barrier.sync(flags: .barrier) {
                notify(task)
            }
        }
    }
}
