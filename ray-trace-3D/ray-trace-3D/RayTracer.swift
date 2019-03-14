//
//  RayTracer.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/14/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Cocoa

extension NSColor {
    var intValue: UInt {
        get {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            getRed(&r, green: &g, blue: &b, alpha: nil)
            return (UInt(r) << 16) | (UInt(g) << 8) | UInt(b)
        }
    }
}

public struct RayTracer {
    public func trace(imageSize: NSSize, scene: Scene) -> NSImage {
        let pixelsWide = Int(imageSize.width)
        let pixelsHigh = Int(imageSize.height)
        
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixelsWide, pixelsHigh: pixelsHigh, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
            fatalError("Error creating bitmap image")
        }
        
        let halfWindowHeight = Double(imageSize.height) / 2
        let halfWindowWidth = Double(imageSize.width) / 2
        let xmin = -halfWindowWidth
        let xmax = halfWindowWidth
        let ymin = -halfWindowHeight
        let ymax = halfWindowHeight
        
        for x in 0..<pixelsWide {
            for y in 0..<pixelsHigh {
                let pixelColor: NSColor
                let ray = primaryRayForPixel(imageSize: imageSize, scene: scene, x: x, y: y, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax)
                if let (point, normal, object) = nearestIntersection(ray: ray, scene: scene) {
                    pixelColor = illuminatedColorForPoint(point: point, normal: normal, ray: ray, object: object, scene: scene, recursionLimit: 3).nsColor()
                    let _ = point
                }
                else {
                    pixelColor = scene.backgroundColor.nsColor()
                }
                bitmap.setColor(pixelColor, atX: x, y: y)
            }
        }
        
        let image = NSImage(size: imageSize)
        image.addRepresentation(bitmap)
        return image
    }
    
    private func nearestIntersection(ray: Ray, scene: Scene) -> (point: Point, normal: Vector, object: Traceable)? {
        var nearestPoint: Point?
        var nearestNormal: Vector?
        var shortestLength = Double.infinity
        var nearestObject: Traceable?
        
        for object in scene.objects {
            if let (point, normal) = object.intersect(ray: ray) {
                let length = (point - ray.origin).length()
                if length < shortestLength {
                    shortestLength = length
                    nearestPoint = point
                    nearestNormal = normal
                    nearestObject = object
                }
            }
        }
        
        if let nearestPoint = nearestPoint,
            let nearestNormal = nearestNormal,
            let nearestObject = nearestObject {
            return (nearestPoint, nearestNormal, nearestObject)
        }
        return nil
    }
    
    private func primaryRayForPixel(imageSize: NSSize, scene: Scene, x: Int, y: Int, xmin: Double, xmax: Double, ymin: Double, ymax: Double) -> Ray {
        let invertY = ymax - Double(y)
        let u = (Double(x) - xmin) * ((scene.viewport.umax - scene.viewport.umin)/(xmax - xmin)) + scene.viewport.umin + scene.viewport.umin
        let v = (invertY - ymin) * ((scene.viewport.vmax - scene.viewport.vmin)/(ymax - ymin)) + scene.viewport.vmin
        
        let screenPoint = Point(x: u, y: v, z: 0)
        var ray = Ray(type: .Primary)
        ray.origin = scene.lookFrom
        ray.direction = (screenPoint - scene.lookFrom).normalized()
        return ray
    }
    
    let epsilon: Double = 10000000
    
    private func isShadowed(point: Point, scene: Scene, lightSource: DirectionalLightSource) -> Bool {
        let shadowRayDirection = lightSource.direction
        let shadowRay = Ray(type: .Shadow, origin: point + (shadowRayDirection / epsilon), direction: shadowRayDirection)
        guard let (_, _, _) = nearestIntersection(ray: shadowRay, scene: scene) else {
            return false
        }
        
        return true
    }
    
    private func illuminatedColorForPoint(point: Point, normal: Vector, ray: Ray, object: Traceable, scene: Scene, recursionLimit: Int) -> Color {
        let cr = object.material.color
        let ca = scene.ambientLight
        let ambient = cr * ca
        
        
        
        switch object.material {
        case let .Diffuse(_, specularHighlight, phongConstant):
            let other = scene.lightSources.reduce(Color.Zero) { sum, light in
                if isShadowed(point: point, scene: scene, lightSource: light) {
                    return sum
                }
                else {
                    let l = light.direction
                    let diffuse = object.material.color * max(0, normal.dot_product(vector: l))
                    let ri = 2 * normal * (normal.dot_product(vector: l)) - l
                    let e = (scene.lookFrom - point).normalized()
                    let specular = specularHighlight * pow(max(0, e.dot_product(vector: ri)), phongConstant)
                    let color = light.color * (diffuse + specular)
                    return sum + color
                }
            }
            
            return (ambient + other).clamp()
            
        case let .Reflective(thisColor):
            let other = scene.lightSources.reduce(Color.Zero) { sum, light in
                if recursionLimit > 0 {
                    let reflectionDirection = ray.direction - (2 * normal * (ray.direction.dot_product(vector: normal)))
                    let reflectionRay = Ray(type: .Reflection, origin: point + (reflectionDirection / epsilon), direction: reflectionDirection.normalized())
                    if let (reflectedPoint, reflectedPointNormal, reflectedObject) = nearestIntersection(ray: reflectionRay, scene: scene) {
                        let reflected = illuminatedColorForPoint(point: reflectedPoint, normal: reflectedPointNormal, ray: reflectionRay, object: reflectedObject, scene: scene, recursionLimit: recursionLimit - 1)
                        return reflected
                    }
                    else {
                        return thisColor
                    }
                }
                else {
                    return scene.backgroundColor
                }
            }
            
            return (ambient + other).clamp()
            
        case let .Transparent(thisColor):
            let other = scene.lightSources.reduce(Color.Zero) { sum, light in
                if recursionLimit > 0 {
                    let incidenceIndex = 1.0 // vacuum
                    let refractionIndex = 1.52 // crown glass
                    let n = incidenceIndex / refractionIndex
                    
                    let cosI = -(normal.dot_product(vector: ray.direction))
                    let sinT2 = n * n * (1 - cosI * cosI)
                    
                    if sinT2 > 1 {
                        fatalError("Bad refraction")
                    }
                    
                    let cosT = sqrt(1 - sinT2)
                    let refractionDirection = ray.direction * n + normal * (n * cosI - cosT)
                    
                    let refractionRay = Ray(type: .Transmission, origin: point + (refractionDirection / epsilon), direction: refractionDirection)
                    if let (refractedPoint, refractedPointNormal, refractedObject) = nearestIntersection(ray: refractionRay, scene: scene) {
                        let refracted = illuminatedColorForPoint(point: refractedPoint, normal: refractedPointNormal, ray: refractionRay, object: refractedObject, scene: scene, recursionLimit: recursionLimit - 1)
                        return sum + refracted
                    }
                    else {
                        return sum + scene.backgroundColor
                    }
                }
                else {
                    return thisColor
                }
            }
            
            return (ambient + other).clamp()
            
        }
    }
}

