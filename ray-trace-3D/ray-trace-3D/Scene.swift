//
//  Scene.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/14/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Cocoa

public struct DirectionalLightSource {
    var direction: Vector // Direction to the light source
    var color: Color
    
    public init(direction: Vector, color: Color) {
        self.direction = direction.normalized()
        self.color = color
    }
}

public struct Scene {
    // TODO
    public var objects = [Traceable]()
    public let lookFrom: Point
    public var backgroundColor = Color(x: 0, y: 0, z: 0)
    public let fieldOfView: Double
    public var viewport: (umin: Double, umax: Double, vmin: Double, vmax: Double)
    public var ambientLight = Color(x: 0.1, y: 0.1, z: 0.1)
    public var lightSources = [DirectionalLightSource]()

    
    
    public init(lookFrom: Point, fieldOfView: Double) {
        self.lookFrom = lookFrom
        self.fieldOfView = fieldOfView
        
        let length = lookFrom.length()
        let halfAngle = fieldOfView / 2
        let x = length * tan(halfAngle * Double.pi / 180)
        viewport = (-x, x, -x, x)
    }
}
