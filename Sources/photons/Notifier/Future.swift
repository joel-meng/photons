//
//  Notifying.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct Future<Value> {
    
    var bind: (AsyncTask<Value>) -> ValueResolving<Value>
    
    public init(_ notify: @escaping (AsyncTask<Value>) -> ValueResolving<Value>) {
        self.bind = notify
    }
}

extension Future {
    
    static func pure() -> Future<Value> {
        return Future<Value> { (task) -> ValueResolving<Value> in
            let notifier = Notifier<Value>()
            notifier.addNotifier(task)
            
            return ValueResolving { value in
                notifier.broadcast(newValue: value)
            }
        }
    }
    
    static func pure(with task: AsyncTask<Value>) -> ValueResolving<Value> {
        let binding = Future<Value> { (task) -> ValueResolving<Value> in
            let notifier = Notifier<Value>()
            notifier.addNotifier(task)
            
            return ValueResolving { value in
                notifier.broadcast(newValue: value)
            }
        }
        
        return binding.bind(task)
    }
    
    static func pure(_ task: @escaping (Value) -> Void) -> ValueResolving<Value> {
        
        let binding = Future<Value> { (task) -> ValueResolving<Value> in
            let notifier = Notifier<Value>()
            notifier.addNotifier(task)
            
            return ValueResolving { value in
                notifier.broadcast(newValue: value)
            }
        }
        
        let action = AsyncTask<Value>(task: task)
        return binding.bind(action)
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
