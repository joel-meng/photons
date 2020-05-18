//
//  Notifying.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation
/*

public class Future<Value> {
    
    private var resolver: ValueResolving<Value>?
    
    public init(complete: AsyncTask<Value>) {
        setComplete(complete)
    }
    
    public init() {}
    
    func resolve(with value: Value) {
        resolver?.resolve(value)
    }
    
    func setComplete<T: Task>(_ complete: T) where T.Value == Value {
        self.resolver = ValueResolving(resolve: {
            let notifier = Notifier<Value>()
            notifier.addNotifier(complete)
            notifier.broadcast(newValue: $0)
        })
    }
}

extension Future {
    
    static func pure() -> Future<Value> {
        return Future<Value>()
    }
    
    static func pure(_ task: @escaping (Value) -> Void) -> Future<Value> {
        return pure(with: AsyncTask<Value>(task))
    }
    
    static func pure(with task: AsyncTask<Value>) -> Future<Value> {
        return Future<Value>(complete: task)
    }
}

extension Future {
    
    func map<NewValue>(_ f: @escaping (Value) -> NewValue) -> Future<NewValue> {
        let newFuture = Future<NewValue>()
        self.setComplete(ImmediateTask<Value> { (value) in
            let converted = f(value)
            newFuture.resolve(with: converted)
        })
        return newFuture
    }
}

extension Future {
    
    func flatMap<NewValue>(_ f: @escaping (Value) -> Future<NewValue>) -> Future<NewValue> {
        let newFuture: Future<NewValue> = Future<NewValue>()
        setComplete(ImmediateTask<Value> { (value) in
            f(value).setComplete(AsyncTask<NewValue> { newValue in
                newFuture.resolve(with: newValue)
            })
        })
        return newFuture
    }
}
*/
