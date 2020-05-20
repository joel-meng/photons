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

    func onComplete(_ completeCallback: @escaping (Value) -> Void)
    
    func subscribeOn(context: @escaping ExectutionContext)
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
    
    public init(_ resolver: (@escaping (Value) -> Void) -> Void) {
        resolver { [weak self] value in
            self?.resolve(with: value)
        }
    }
    
    // MARK: - Static constructor
    
    public static func pure(_ onComplete: @escaping (Value) -> Void) -> Future<Value> {
        let future = Future()
        future.onComplete(onComplete)
        return future
    }
    
    // MARK: - Listening
    
    public func onComplete(_ completeCallback: @escaping (Value) -> Void) {
        mutexQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.listeners.append(completeCallback)
            self.result.map(completeCallback)
        }
    }
    
    public func subscribeOn(context: @escaping ExectutionContext) {
        mutexQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.subscriptionContext = context
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
        mutexQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.result = value
            self.listeners.forEach { listener in
                self.subscriptionContext {
                    listener(value)
                }
            }
        }
    }
}

// MARK: - Functional

extension Future {

    func map<U>(_ f: @escaping (Value) -> U) -> Future<U> {
        let newFuture = Future<U>()
        onComplete { value in
            newFuture.resolve(with: f(value))
        }
        return newFuture
    }
    
    func flatMap<U>(_ f: @escaping (Value) -> Future<U>) -> Future<U> {
        let newFuture = Future<U>()
        onComplete { value in
            f(value).onComplete { valueU in
                newFuture.resolve(with: valueU)
            }
        }
        return newFuture
    }
}
