//
//  DispatchQueue+PrivateQueue.swift
//  photons
//
//  Created by Jun Meng on 13/5/20.
//

import Foundation

let barrierConcurrentQueue: DispatchQueue = DispatchQueue(label: "barrierConcurrentQueue/joel.meng",
                                                          qos: .background,
                                                          attributes: .concurrent)

let concurrentQueue: DispatchQueue = DispatchQueue(label: "concurrentQueue/joel.meng",
                                                   qos: .background,
                                                   attributes: .concurrent)


extension DispatchQueue {
    
    static var barrier: DispatchQueue { barrierConcurrentQueue }
    
    static var background: DispatchQueue { concurrentQueue }
}
