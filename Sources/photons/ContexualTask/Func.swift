//
//  Task.swift
//  photons
//
//  Created by Jun Meng on 15/5/20.
//

import Foundation

public struct Func<Input> {
    
    var run: (Input) -> Void
    
    public init(_ run: @escaping (Input) -> Void) {
        self.run = run
    }
    
    public func execute(_ value: Input) {
        run(value)
    }
    
    // MARK: - Wrap In Context
    
    public static func atomic(_ run: @escaping (Input) -> Void) -> Func<Input> {
        return Func<Input> { input in
            mutexContext {
                run(input)
            }
        }
    }
     
    public static func main(_ run: @escaping (Input) -> Void) -> Func<Input> {
        Func<Input> { input in
            mainContext {
                 run(input)
             }
         }
    }
     
    public static func background(run: @escaping (Input) -> Void) -> Func<Input> {
        Func<Input> { input in
            backgroundContext {
                run(input)
            }
        }
    }
    
    public static func delayed(for timeInterval: DispatchTimeInterval, run: @escaping (Input) -> Void) -> Func<Input> {
        Func<Input> { input in
            (delayContext(timeInterval)) {
                run(input)
            }
        }
    }
}
