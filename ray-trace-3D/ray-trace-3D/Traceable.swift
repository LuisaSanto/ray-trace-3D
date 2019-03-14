//
//  Traceable.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/14/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Cocoa

public protocol Traceable {
    var material: Material { get }
    func intersect(ray: Ray) -> (point: Point, normal: Vector)?
}
