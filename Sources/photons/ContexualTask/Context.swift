//
//  Context.swift
//  photons
//
//  Created by Jun Meng on 15/5/20.
//

import Foundation

public struct Context<Input> {
    
    private var run: (Input) -> Void
    
    // MARK: - Initialize
    
    public init(_ task: Func<Input>) {
        self.run = { value in
            task.execute(value)
        }
    }
    
    // MARK: - Execute
    
    func execute(_ value: Input) {
        self.run(value)
    }

    // MARK: - Pure
    
    public static func pure(_ task: Func<Input>) -> Context<Input> {
        return Context<Input>(task)
    }
    
    // MARK: - Run In Main Context
    
    func main() -> Context<Input> {
        let newTask = Func<Input> { input in
            mainContext {
                self.execute(input)
            }
        }
        return Context<Input>(newTask)
    }
    
    // MARK: - Run In Background Context
    
    func background() -> Context<Input> {
        let newTask = Func<Input> { input in
            backgroundContext {
                self.execute(input)
            }
        }
        return Context<Input>(newTask)
    }
    
    // MARK: - Run In Delayed Context
    
    func delay(_ delay: DispatchTimeInterval) -> Context<Input> {
        let newTask = Func<Input> { input in
            (delayContext(delay)) {
                self.execute(input)
            }
        }
        return Context<Input>(newTask)
    }
    
    // MARK: - Run In Atomic Context
    
    func atomic() -> Context<Input> {
        let newTask = Func<Input> { input in
            mutexContext {
                self.execute(input)
            }
        }
        return Context<Input>(newTask)
    }
}
