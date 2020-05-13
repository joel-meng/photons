//
//  AtomicNotifying.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

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
