//
//  Resolver.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

struct Resolver<Value> {
    
    private var value: Atomic<Value>
    
    init(value: Value) {
        self.value = Atomic<Value>(value)
    }

    mutating func resolve(with newValue: Value) {
        value.value {
            $0 = newValue
        }
    }
}
