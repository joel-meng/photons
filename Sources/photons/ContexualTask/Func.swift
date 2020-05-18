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
    
    func atomic() -> Func<Input> {
        return Func<Input> { input in
            mutexContext {
                self.run(input)
            }
        }
    }
     
    func main() -> Func<Input> {
        Func<Input> { input in
            mainContext {
                 self.run(input)
             }
         }
    }
     
    func background() -> Func<Input> {
        Func<Input> { input in
            backgroundContext {
                self.run(input)
            }
        }
    }
    
    func delayed(for timeInterval: DispatchTimeInterval) -> Func<Input> {
        Func<Input> { input in
            (delayContext(timeInterval)) {
                self.run(input)
            }
        }
    }
    
    
    
//    func main() -> Context<Input> {
//        Context(self).main()
//    }
//
//    func background() -> Context<Input> {
//        Context(self).background()
//    }
//
//    func delayed(for timeInterval: DispatchTimeInterval) -> Context<Input> {
//        Context(self).delay(timeInterval)
//    }
//
//    func atomic() -> Context<Input> {
//        Context(self).atomic()
//    }
}
