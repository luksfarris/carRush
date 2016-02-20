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
    var car:SCNNode!
    var scene:SCNScene!
    var sceneView:SCNView!
    var onLeftLane:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createScene()
        createCamera()
        createGround()
        createScenario()
        createPlayer()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:"move:")
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "move:")
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        sceneView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func move(sender: UITapGestureRecognizer){
        let position = sender.locationInView(self.view) // pegamos a localizacao do gesto
        let right = position.x > self.view.frame.size.width/2 // se o gesto foi na esquerda ou direita da tela
        if right == onLeftLane { // se estamos na esquerda querendo ir pra direita, ou na direita querendo ir pra esquerda
            let moveSideways:SCNAction = SCNAction.moveByX((right ? 7.5:-7.5), y: 0, z: 0, duration: 0.2)
            moveSideways.timingMode = SCNActionTimingMode.EaseInEaseOut // suaviza o inicio e o fim da animacao
            car.runAction(moveSideways)
            onLeftLane = !right // atualiza a posicao do carro
        }
    }
    
    func createPlayer(){
        let carScene = SCNScene(named: "car.scn")
        car = carScene!.rootNode.childNodeWithName("car", recursively: true)
        scene.rootNode.addChildNode(car)
        car.position = SCNVector3(-2.5,0,-25) // colocamos ele na frente da camera
        car.eulerAngles = SCNVector3(0,M_PI_2,0) // rodamos 90 graus ortogonalmente ao chao
        car.scale = SCNVector3(2,2,2) // duplicamos o tamanho do carro
        
        let particleSystem = SCNParticleSystem(named: "SmokeParticles", inDirectory: nil)
        let exausterNode = SCNNode(geometry: SCNBox(width: 0, height: 0, length: 0, chamferRadius: 1))
        exausterNode.position = SCNVector3(-1,0.2,-0.5)
        exausterNode.addParticleSystem(particleSystem!)
        car.addChildNode(exausterNode)
    }
    
    func createScenario() {
        for i in 20...70 {
            let laneMaterial = SCNMaterial()
            if i%5<2 {
                laneMaterial.diffuse.contents = UIColor.clearColor()
            } else {
                laneMaterial.diffuse.contents = UIColor.blackColor()
            }
            let laneGeometry = SCNBox(width: 0.2, height: 0.1, length: 1, chamferRadius:0)
            laneGeometry.materials = [laneMaterial]
            let lane = SCNNode(geometry: laneGeometry)
            lane.position = SCNVector3(x: 0, y: 0, z: -Float(i))
            scene.rootNode.addChildNode(lane)
            let moveDown = SCNAction.moveByX(0, y:0 , z: 5, duration: 0.3)
            let moveUp = SCNAction.moveByX(0, y: 0, z: -5, duration: 0)
            let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
            lane.runAction(moveLoop)
        }
    }
    
    func createScene () {
        scene = SCNScene()
        sceneView = self.view as! SCNView
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.playing = true
        sceneView.autoenablesDefaultLighting = true
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
        groundMaterial.diffuse.contents = UIColor.whiteColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        scene.rootNode.addChildNode(ground)
    }
    
}
