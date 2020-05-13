//
//  Resolving.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct ValueResolving<Value> {
    
    var resolve: (Value) -> Void
    
    public init(resolve: @escaping (Value) -> Void) {
        self.resolve = resolve
    }
}
