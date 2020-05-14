//
//  Notifier.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

struct Notifier<Value> {
    
    private var notifiers: Atomic<[AnyTask<Value>]> = Atomic<[AnyTask<Value>]>([])
    
    func addNotifier<T: Task>(_ notifier: T) where T.Value == Value {
        notifiers.value {
            $0.append(AnyTask<Value>(task: notifier))
        }
    }
    
    func broadcast(newValue: Value) {
        for notifier in notifiers.value {
            notifier.run(newValue)
        }
    }
}
