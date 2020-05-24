//
//  Future+Functional.swift
//  photons
//
//  Created by Jun Meng on 22/5/20.
//

import Foundation

extension Future {
    
    // MARK: - Map
    
    public func map<U>(f: @escaping (Value) -> U) -> Future<U> {
        let newFuture = Future<U>()
        subscribe(on: currentContext) { value in
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
        subscribe(on: currentContext) { value in
            f(value).subscribe(on: currentContext) { valueU in
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
