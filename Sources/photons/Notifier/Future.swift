//
//  Notifying.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public class NFuture<Value> {
    
    private var resolver: ValueResolving<Value>?
    
    public init(complete: AsyncTask<Value>) {
        setComplete(complete)
    }
    
    public init() {}
    
    func resolve(with value: Value) {
        resolver?.resolve(value)
    }
    
    func setComplete(_ complete: AsyncTask<Value>) {
        self.resolver = ValueResolving(resolve: {
            let notifier = Notifier<Value>()
            notifier.addNotifier(complete)
            notifier.broadcast(newValue: $0)
        })
    }
    
    func map<NewValue>(_ f: @escaping (Value) -> NewValue) -> NFuture<NewValue> {
        let newFuture = NFuture<NewValue>()
        self.setComplete(AsyncTask<Value>(task: { (value) in
            let converted = f(value)
            newFuture.resolver?.resolve(converted)
        }))
        return newFuture
    }
}

public struct Future<Value> {
    
    var bind: (AsyncTask<Value>) -> ValueResolving<Value>
    
    public init(_ binding: @escaping (AsyncTask<Value>) -> ValueResolving<Value>) {
        self.bind = binding
    }
}

extension Future {
    
    func map<NewValue>(_ f: @escaping (Value) -> NewValue) {// -> ValueResolving<Value> {
//        let newBinder = Future<NewValue> { task -> ValueResolving<NewValue> in
//            let notifier = Notifier<NewValue>()
//            notifier.addNotifier(task)
//
//            return ValueResolving { value in
//                notifier.broadcast(newValue: value)
//            }
//        }
//
//        let asyncTask = AsyncTask<NewValue> { newValue in
//
//        }
//
//        newBinder.bind(asyncTask)
//
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
