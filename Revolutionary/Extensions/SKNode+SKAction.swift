//
//  SKNode+SKAction.swift
//  Revolutionary
//
//  Created by Guilherme Carlos Matuella on 24/08/18.
//  Copyright © 2018 gmatuella. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    func run(_ action: SKAction, withKey key: String, completion: Completion?) {
        if let completion = completion {
            let completionAction = SKAction.run(completion)
            let compositeAction = SKAction.sequence([action, completionAction])
            
            run(compositeAction, withKey: key)
        } else {
            run(action, withKey: key)
        }
    }   
}
