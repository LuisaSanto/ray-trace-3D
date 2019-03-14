//
//  Polygon.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/14/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Cocoa

typealias Point2D = (Double, Double)

func - (left: Point2D, right: Point2D) -> Point2D {
    return (left.0 - right.0, left.1 - right.1)
}

public struct Polygon: Traceable {
    public var material: Material
    public var points: [Point]
    public var isSingleSided = false
    
    public init(points: [Point], material: Material) {
        self.points = points
        self.material = material
    }
    
    func planeIntersection(ray: Ray) -> (Point, Vector)? {
        let v1 = self.points[1] - self.points[0]
        let v2 = self.points[0] - self.points[2]
        var normal = (v1.cross_product(vector: v2)).normalized()
        
        let vd = normal.dot_product(vector: ray.direction)
        
        if vd >= 0 && isSingleSided {
            // means noraml is points away from ray and this is a one sided shape
            return nil
        }
        
        if vd == 0 {
            // means ray parallel to line
            return nil
        }
        
        let d = -(normal.cross_product(vector: points[0])) // distance from plane to origin
        let vo = -(normal.dot_product(vector: ray.origin + d))
        let t = vo / vd
        
        if t < 0 {
            //intersection is behind camera
            return nil
        }
        
        if vd > 0 {
            //reserse the plane's normal
            normal = -normal
        }
        
        let intersection = ray.origin + (ray.direction * t)
        return (intersection, normal)
    }
    
    func containsPoint(point: Point, normal: Vector) -> Bool {
        // determine dominate coordinate and drop it from interesction point and
        // all polygon coordinates to project them on to the appropriate axis
        // AND translate the plane intersection point to the origin
        
        let uvCoordinates: [Point2D]
        let projectedPoint: Point2D
        
        if normal.x > normal.y && normal.x >= normal.z {
            projectedPoint = (point.y, point.z)
            uvCoordinates = points.map{ ($0.y , $0.z) - projectedPoint }
        } else if normal.y >= normal.x && normal.y >= normal.z {
            projectedPoint = (point.x, point.z)
            uvCoordinates = points.map { ($0.x , $0.z) - projectedPoint }
        } else {
            projectedPoint = (point.x, point.y)
            uvCoordinates = points.map { ($0.x, $0.y) - projectedPoint }
        }
        
        var numCrossings = 0
        var signHolder = uvCoordinates[0].1 < 0 ? -1 : 1
        
        for (i, (ui, vi)) in uvCoordinates.enumerated() {
            let nextIndex = i == uvCoordinates.count - 1 ? 0 : i + 1
            let (ui1, vi1) = uvCoordinates[nextIndex]
            let nextSignHolder = vi1 < 0 ? -1 : 1
            if signHolder != nextSignHolder {
                if ui > 0 && ui1 > 0 { // this edge crosses +u'
                    numCrossings = numCrossings + 1
                }
                else if ui > 0 || ui1 > 0 { // the edge might cross +u
                    let ucross = ui - vi * (ui1 - ui) / (vi1 - vi)
                    if ucross > 0 {
                        numCrossings = numCrossings + 1
                    }
                }
            }
            signHolder = nextSignHolder
        }
        return numCrossings % 2 != 0
    }
    
    
    public func intersect(ray: Ray) -> (point: Point, normal: Vector)? {
        guard let (intersectionPoint, normal) = planeIntersection(ray: ray) else { return nil }
        
        if containsPoint(point: intersectionPoint, normal: normal) {
            return (intersectionPoint, normal)
        } else {
            return nil
        }
    }
    
}
