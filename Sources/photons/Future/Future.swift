//
//  Future.swift
//  photons
//
//  Created by Jun Meng on 17/5/20.
//

import Foundation

typealias FutureType = FutureUpdater & FutureObserver

// MARK: - Future Updater

/// An protocol exposes to future updater functions that to tell a `Future` a value is ready or error happened.
public protocol FutureUpdater {

    associatedtype Value

    /// Tell `Future` that a value is ready
    /// - Parameter value: The value to pass to `Future`
    func resolve(with value: Value)
}

// MARK: - Future Observer

/// An protocol exposes functions to future listeners about `Future` result updated.
public protocol FutureObserver {

    associatedtype Value

    func onComplete(subscribeOn: @escaping ExectutionContext,
                    completeCallback: @escaping (Value) -> Void)
}

public class Future<Value>: FutureType {

    /// Listeners who is observing result's update
    lazy var listeners: [(Value) -> Void] = []

    /// Result data that to be notified in future.
    private(set) var result: Value?
    
    private(set) var subscriptionContext = currentContext
    
    private let mutexQueue = DispatchQueue(label: "Future-Mutex-Queue", attributes: .concurrent)

    // MARK: - Initializer

    public init() {
        result = nil
    }

    public init(_ value: Value) {
        result = value
    }
    
    public init(resolver: (@escaping (Value) -> Void) -> Void) {
        resolver { value in
            self.resolve(with: value)
        }
    }
    
    // MARK: - Static constructor
    
    public static func pure(subscribeOn subscribeContext: @escaping ExectutionContext = backgroundContext,
                            onComplete: @escaping (Value) -> Void) -> Future<Value> {
        let future = Future()
        future.onComplete(subscribeOn: subscribeContext, completeCallback: onComplete)
        return future
    }
    
    // MARK: - Listening
    
    public func onComplete(subscribeOn subscribeContext: @escaping ExectutionContext = backgroundContext,
                           completeCallback: @escaping (Value) -> Void) {
        mutexQueue.async(flags: .barrier) {
            let wrapper: (Value) -> Void = { result in
                subscribeContext {
                    completeCallback(result)
                }
            }
            
            self.listeners.append(wrapper)
            if let result  = self.result {
                wrapper(result)
            }
        }
    }

    // MARK: - Result updating
    
    public func resolve(with value: Value) {
        // This block is a `barrier` concurrent queue closure, which make sure
        // 1. Assigning `result` value and
        // 2. Broadcasting `result` value change are atomic
        // So that during `result` value would not be updated during broadcasting.
        // However, it does not gurantee the `completions` are started/completed in any order, but only all added
        // `completion`s are being notified.
        mutexQueue.async(flags: .barrier) {
            self.result = value
            self.listeners.forEach { listener in
                listener(value)
            }
        }
    }
}

// MARK: - Functional

extension Future {
    
    // MARK: - Map
    
    func map<U>(f: @escaping (Value) -> U) -> Future<U> {
        let newFuture = Future<U>()
        onComplete(subscribeOn: currentContext) { value in
            newFuture.resolve(with: f(value))
        }
        return newFuture
    }
    
    public static func map<A, B>(future: Future<A>, f: @escaping (A) -> B) -> Future<B> {
        future.map(f: f)
    }
    
    // MARK: - FlatMap
    
    public func flatMap<U>(f: @escaping (Value) -> Future<U>) -> Future<U> {
        let newFuture = Future<U>()
        onComplete(subscribeOn: currentContext) { value in
            f(value).onComplete(subscribeOn: currentContext) { valueU in
                newFuture.resolve(with: valueU)
            }
        }
        return newFuture
    }
    
    public static func flatMap<A, B>(future: Future<A>, f: @escaping (A) -> Future<B>) -> Future<B> {
        future.flatMap(f: f)
    }
    
    // MARK: - Zip
    
    public func zip<A>(subscribeOn subscribeContext: @escaping ExectutionContext = backgroundContext,
                       with anotherFuture: Future<A>) -> Future<(Value, A)> {
        flatMap { (thisValue) -> Future<(Value, A)> in
            anotherFuture.map { anotherValue in
                (thisValue, anotherValue)
            }
        }
    }
    
    public static func flatMap<A, B>(lhf: Future<A>, rhf: Future<B>) -> Future<(A, B)> {
        lhf.zip(with: rhf)
    }
}

precedencegroup infix0 {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator >>>: infix0
func >>> <A, B>(future: Future<A>, f: @escaping (A) -> B) -> Future<B> {
    future.map(f: f)
}

infix operator |||: infix0
func ||| <A, B>(future: Future<A>, f: @escaping (A) -> Future<B>) -> Future<B> {
    future.flatMap(f: f)
}

infix operator +++: infix0
func +++ <A, B>(lhf: Future<A>, rhf: Future<B>) -> Future<(A, B)> {
    lhf.zip(with: rhf)
}
