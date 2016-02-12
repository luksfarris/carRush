//
//  GameViewController.swift
//  Cars3d
//
//  Created by Lucas Farris on 12/02/16.
//  Copyright (c) 2016 Farris. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    var camera:SCNNode!
    var ground:SCNNode!
    var scene:SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createScene()
        createCamera()
        createGround()
    }
    
    func createScene () {
        scene = SCNScene()
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.playing = true
        scnView.autoenablesDefaultLighting = true
    }
    
    func createCamera () {
        camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(x: 0, y: 25, z: -18)
        camera.eulerAngles = SCNVector3(x: -1, y: 0, z: 0)
        camera.camera?.aperture = 1/2
        scene.rootNode.addChildNode(camera)
    }
    
    func createGround () {
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.5
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.darkGrayColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        scene.rootNode.addChildNode(ground)
    }
    
}
