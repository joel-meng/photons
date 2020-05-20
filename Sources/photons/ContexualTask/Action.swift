//
//  Action.swift
//  photons
//
//  Created by Jun Meng on 19/5/20.
//

import Foundation

public struct Action {
    
    var run: () -> Void
    
    public init(_ run: @escaping () -> Void) {
        self.run = run
    }
    
    // MARK: - Wrap In Context
     
    public static func main(_ run: @escaping () -> Void) -> Action {
        Action {
            mainContext {
                 run()
             }
         }
    }
     
    public static func background(run: @escaping () -> Void) -> Action {
        Action {
            backgroundContext {
                run()
            }
        }
    }
    
    public static func delayed(for timeInterval: DispatchTimeInterval,
                               run: @escaping () -> Void) -> Action {
        Action {
            (delayContext(timeInterval)) {
                run()
            }
        }
    }
}
