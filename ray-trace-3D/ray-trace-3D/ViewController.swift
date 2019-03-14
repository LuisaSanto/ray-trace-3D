//
//  ViewController.swift
//  ray-trace-3D
//
//  Created by Luisa Santo on 3/13/19.
//  Copyright © 2019 Luisa Santo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var ImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "P3D Ray Tracer"
    }
    
    override func viewDidLayout() {
        let imageSize = view.bounds.size
        let rayTracer = RayTracer()
        let image = rayTracer.trace(imageSize: imageSize, scene: scene())
        ImageView.image = image
    }
    
    func scene() -> Scene {
        var scene = Scene(lookFrom: Point(x: 2.1, y: 1.3, z: 1.7), fieldOfView: 45)
        print(scene.viewport)
        scene.backgroundColor = Color(x: 0.078, y: 0.361, z: 0.753)
        let sphere1 = Sphere(center: Point(x: 0, y: 0, z: 0), radius: 0.5, material: .Diffuse(color: Color(x: 1, y: 0, z: 0), specularHighlight: Color(x: 1, y: 1, z: 1), phongConstant: 16))
        let sphere2 = Sphere(center: Point(x: 0.27, y: 0.27, z: 0.54), radius: 0.16, material: .Diffuse(color: Color(x: 1, y: 0, z: 0), specularHighlight: Color(x: 1, y: 1, z: 1), phongConstant: 16))
        let sphere3 = Sphere(center: Point(x: 0.64, y: 0.17, z: 1.11e-16), radius: 0.16, material: .Diffuse(color: Color(x: 1, y: 0, z: 0), specularHighlight: Color(x: 1, y: 1, z: 1), phongConstant: 16))
        let sphere4 = Sphere(center: Point(x: 0.17, y: 0.64, z: 0.54), radius: 0.16, material: .Diffuse(color: Color(x: 1, y: 0, z: 0), specularHighlight: Color(x: 1, y: 1, z: 1), phongConstant: 16))
        scene.objects = [sphere1, sphere2, sphere3, sphere4]
        //        scene.ambientLight = Color(0.3, 0.3, 0.3)
        let lightSource1 = DirectionalLightSource(direction: Vector(x: 4, y: 3, z: 2), color: Color(x: 1, y: 1, z: 1))
        let lightSource2 = DirectionalLightSource(direction: Vector(x: 1, y: -4, z: 4), color: Color(x: 1, y: 1, z: 1))
        let lightSource3 = DirectionalLightSource(direction: Vector(x: -3, y: 1, z: 5), color: Color(x: 1, y: 1, z: 1))
        scene.lightSources.append(lightSource1)
        scene.lightSources.append(lightSource2)
        scene.lightSources.append(lightSource3)
        return scene
    }
}

