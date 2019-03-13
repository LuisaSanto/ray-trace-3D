//
//  Ray.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/13/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import GLKit
 
public struct Ray: CustomStringConvertible {
    public var type: Type
    public var origin: Point
    public var direction: Vector
    public var description: String { return "\(type). Origin: \(origin), Direction: \(direction)" }
    
    public init(type: Type, origin: Point = Point.Zero, direction: Vector = Vector.Zero) {
        self.type = type
        self.origin = origin
        self.direction = direction
    }
    
    public enum `Type`: CustomStringConvertible {
        case Primary
        case Reflection
        case Transmission
        case Shadow
        
        public var description: String {
            switch self {
            case .Primary: return "Primary"
            case .Reflection: return "Reflection"
            case .Transmission: return "Transmission"
            case .Shadow: return "Shadow"
            }
        }
    }
    
}
