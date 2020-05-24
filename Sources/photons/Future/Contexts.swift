//
//  Contexts.swift
//  photons
//
//  Created by Jun Meng on 15/5/20.
//

import Foundation

public typealias ExectutionContext = (@escaping () -> Void) -> Void

// MARK: - Current Context

public let currentContext: ExectutionContext = { task in
    task()
}

// MARK: - Main Context

public let mainContext: ExectutionContext = { task in
    guard Thread.current.isMainThread else {
        DispatchQueue.main.async { task() }
        return
    }
    task()
}

// MARK: - Delay Context

public let delayContext: (DispatchTimeInterval) -> ExectutionContext = { delay in
    { task in
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
            task()
        }
    }
}

// MARK: - Background Context

public let backgroundContext: ExectutionContext = { task in
    guard !Thread.current.isMainThread else {
        DispatchQueue.global().async { task() }
        return
    }
    task()
}

// MARK: - Atomic Cotnext

let mutex: DispatchQueue = DispatchQueue(label: "Photons-Mutext-Concurrency-Queue", attributes: .concurrent)
let mutexContext: ExectutionContext = { task in
    mutex.async(flags: .barrier) {
        task()
    }
}
