//
//  Notifier.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

struct Notifier<Value> {
    
    private var notifiers: Atomic<[AsyncTask<Value>]> = Atomic<[AsyncTask<Value>]>([])
    
    func addNotifier(_ notifier: AsyncTask<Value>) {
        notifiers.value {
            $0.append(notifier)
        }
    }
    
    func broadcast(newValue: Value) {
        for notifier in notifiers.value {
            notifier.run(newValue)
        }
    }
}
