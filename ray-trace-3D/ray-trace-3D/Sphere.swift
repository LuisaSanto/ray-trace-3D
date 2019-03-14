//
//  Sphere.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/13/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Foundation
import GLKit

public struct Sphere: Traceable {
    public var material: Material
    public var radius: Double
    public var center: Point
    
    public init(center: Point = Point.Zero, radius: Double = 0, material: Material){
        self.center = center
        self.radius = radius
        self.material = material
    }
    
    
    public func intersect(ray: Ray) -> (point: Point, normal: Vector)? {
        // Calculate B & C of quadratic
        let B = 2 * ray.direction.dot_product(vector: ray.origin - center)
        let oc = ray.origin - center
        let C = (oc.dot_product(vector: oc)) - (radius * radius)
        
        // Calculate the discriminant
        let D = B * B - 4 * C
        if D < 0 {
            return nil  // ray does not intersect the sphere - no root
        }
        
        let t: Double
        
        // Calculate smaller intersection parameter: t0
        let t0 = (-B - sqrt(D)) / 2
        if t0 <= 0 {
            // Calculate larger t-value: t1
            let t1 = (-B + sqrt(D)) / 2
            if t1 <= 0 {
                return nil  // intersection point behind ray
            }
            t = t1
        } else {
            t = t0
        }
    
        let point  = ray.origin + ray.direction * t
        let normal = (point - center) / radius
        return (point, normal)
    }
}
