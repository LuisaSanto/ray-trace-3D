//
//  Vector.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/13/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import GLKit

public struct Vector: Equatable, CustomStringConvertible {
    public var x: Double
    public var y: Double
    public var z: Double
    public var description: String { return "(\(x), \(y), \(z))" }
    public static var Zero: Vector { get { return Vector(x: 0, y: 0, z: 0) } }
    
    public init (x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    
    public func dot_product(vector: Vector) -> Double {
        return x * vector.x + y * vector.y + z * vector.z
    }
    
    
    public func cross_product(vector: Vector) -> Vector {
        return Vector(x: y * vector.z - z * vector.y, y: z * vector.x - x * vector.z, z: x * vector.y - y * vector.x)
    }
    
    
    public func length() -> Double {
        return sqrt(x * x + y * y + z * z)
    }
    
    
    public func normalized() -> Vector {
        let l = length()
        return l == 0 ? Vector.Zero : self / l
    }
}


public typealias Point = Vector
public typealias Color = Vector


public extension Color {
    
    public func clamp() -> Color {
        return Color(x: min(x, 1), y: min(y, 1), z: min(z, 1))
    }
    
    public func nsColor() -> NSColor {
        return NSColor(calibratedRed: CGFloat(x), green: CGFloat(y), blue: CGFloat(z), alpha: 1)
    }
    
}


public func + (left: Vector, right: Vector) -> Vector {
    return Vector(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}


public func - (left: Vector, right: Vector) -> Vector {
    return Vector(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}


public prefix func - (vector: Vector) -> Vector {
    return Vector.Zero - vector
}


public func == (left: Vector, right: Vector) -> Bool {
    return left.x == right.x && left.y == right.y && left.z == right.z
}


public func * (left: Double, right: Vector) -> Vector {
    return Vector(x: left * right.x, y: left * right.y, z: left * right.z)
}


public func * (left: Vector, right: Double) -> Vector {
    return Vector(x: right * left.x, y: right * left.y, z: right * left.z)
}


public func * (left: Vector, right: Vector) -> Vector {
    return Vector(x: left.x * right.x, y: left.y * right.y, z: left.z * right.z)
}


public func / (left: Vector, right: Double) -> Vector {
    return Vector(x: left.x / right, y: left.y / right, z: left.z / right)
}
