//
//  Operators.swift
//  photons
//
//  Created by Jun Meng on 24/5/20.
//

import Foundation

precedencegroup infix0 {
    associativity: left
    higherThan: AssignmentPrecedence
}

// MARK: - Map operator

infix operator >>>: infix0
func >>> <A, B>(future: Future<A>, f: @escaping (A) -> B) -> Future<B> {
    future.map(f: f)
}

// MARK: - FlatMap operator

infix operator |||: infix0
func ||| <A, B>(future: Future<A>, f: @escaping (A) -> Future<B>) -> Future<B> {
    future.flatMap(f: f)
}

// MARK: - Zip operator

infix operator +++: infix0
func +++ <A, B>(lhf: Future<A>, rhf: Future<B>) -> Future<(A, B)> {
    lhf.zip(with: rhf)
}
