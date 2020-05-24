//
//  Future+Result.swift
//  photons
//
//  Created by Jun Meng on 24/5/20.
//

import Foundation

public protocol ResultType {
    associatedtype Value
    associatedtype Error: Swift.Error

    var result: Result<Value, Error> { get }
    
    var value: Value? { get }
    
    var error: Error? { get }
}

extension Result: ResultType {
    
    public typealias Value = Success
    
    public typealias Error = Failure
    
    public var value: Success? {
        switch self {
        case .success(let success):
            return success
        default:
            return nil
        }
    }
    
    public var error: Failure? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
    
    public var result: Result<Success, Failure> {
        self
    }
}

extension Future where Value: ResultType {
    
    public func subscribeSuccess(on context: @escaping ExectutionContext = backgroundContext,
                                 success: @escaping (Value.Value) -> Void) {
        subscribe(on: context, completeCallback: ({ (result) in
            result.value.map(success)
        }))
    }
    
    public func subscribeError(on context: @escaping ExectutionContext = backgroundContext,
                               error: @escaping (Value.Error) -> Void) {
        subscribe(on: context, completeCallback: ({ (result) in
            result.error.map(error)
        }))
    }
    
    public func subscribe(on context: @escaping ExectutionContext = backgroundContext,
                   success: @escaping (Value.Value) -> Void,
                   error: @escaping (Value.Error) -> Void) {
        subscribe(on: context, completeCallback: ({ (result) in
            switch result.result {
            case .success(let successValue): success(successValue)
            case .failure(let errorValue): error(errorValue)
            }
        }))
    }
}
