//
//  Material.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/14/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Cocoa

public enum Material {
    case Diffuse(color: Color, specularHighlight: Color, phongConstant: Double)
    case Reflective(color: Color)
    case Transparent(color: Color)
    
    public var color: Color {
        switch self {
        case let .Diffuse(color: color, specularHighlight: _, phongConstant: _): return color
        case let .Reflective(color): return color
        case let .Transparent(color): return color
        }
    }
}
