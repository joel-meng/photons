//
//  AsyncAction.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

public struct AsyncAction {
    
    private let queue: DispatchQueue
    
    private let action: () -> Void
    
    init(_ run: @escaping () -> Void) {
        self.queue = DispatchQueue.global()
        self.action = run
    }
    
    init(queue: DispatchQueue, action: @escaping () -> Void) {
        self.queue = queue
        self.action = action
    }
    
    func run() {
        queue.async {
            self.action()
        }
    }
}
