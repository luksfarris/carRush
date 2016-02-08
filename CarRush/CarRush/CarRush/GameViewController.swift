//
//  GameViewController.swift
//  CarRush
//
//  Created by Lucas Farris on 02/02/16.
//  Copyright (c) 2016 Farris. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate {

    let CarCategory:NSInteger = 1
    let EnemyCategory:NSInteger = 2
    let GroundCategory:NSInteger = 3
    let WallCategory:NSInteger = 4
    
    
    var lives:NSInteger = 3;
    var score:NSInteger = 0;
    var carNode:SCNNode!
    var cameraNode:SCNNode!
    var ground:SCNNode!
    var wallNode:SCNNode!
    var text:SCNText!
    var scene:SCNScene!
    var currentLane:NSInteger = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        createCamera()
        createLanes()
        createCar()
        createGround()
        createWall()
        createSideWalks()
        createLights()
        createScore()
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.showsStatistics = true
        scnView.playing = true
        scnView.autoenablesDefaultLighting = false
        scnView.scene?.physicsWorld.contactDelegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:"move:")
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "move:")
        scnView.addGestureRecognizer(tapGestureRecognizer)
        scnView.addGestureRecognizer(swipeGestureRecognizer)
        
        createRandomEnemy()
        for i in 30...40 {
            performSelector("createRandomEnemy", withObject:nil , afterDelay: Double.init(i*5)/M_PI)
        }
    }
    
    func move(sender: UITapGestureRecognizer){
        let position = sender.locationInView(self.view)
        let right = position.x > self.view.frame.size.width/2
        if (right && currentLane < 3) || (!right && currentLane>0) {
            var moveUp:SCNAction!
            var startDrift:SCNAction!
            var endDrift:SCNAction!
            if right {
                moveUp = SCNAction.moveByX(5, y: 0, z: 0, duration: 0.2)
                startDrift = SCNAction.rotateByX(0, y: 0, z: -0.2, duration: 0.1)
                endDrift = SCNAction.rotateByX(0, y: 0, z: 0.2, duration: 0.1)
            } else {
                moveUp = SCNAction.moveByX(-5, y: 0, z: 0, duration: 0.2)
                startDrift = SCNAction.rotateByX(0, y: 0, z: 0.2, duration: 0.1)
                endDrift = SCNAction.rotateByX(0, y: 0, z: -0.2, duration: 0.1)
            }
            moveUp.timingMode = SCNActionTimingMode.EaseInEaseOut
            let drift = SCNAction.sequence([startDrift,endDrift])
            let moveSequence = SCNAction.group([moveUp, drift])
            let moveLoop = SCNAction.repeatAction(moveSequence, count: 1)
            carNode.runAction(moveLoop)
            
            if right {
                currentLane += 1
            } else {
                currentLane -= 1
            }
        }
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        if (contact.nodeA == carNode || contact.nodeB == carNode) {
            let enemyNode = contact.nodeA == carNode ? contact.nodeB : contact.nodeA
            if enemyNode.particleSystems == nil {
                let particleSystem = SCNParticleSystem(named: "Explosion", inDirectory: nil)
                enemyNode.addParticleSystem(particleSystem!)
                let finishAttack = SCNAction.moveByX(0, y: 0, z: 10, duration: 1)
                let spin = SCNAction.rotateByX(CGFloat(M_PI_2), y: 0, z: 0, duration: 0.1)
                let spinLoop = SCNAction.repeatAction(spin, count: 10)
                let moveSequence = SCNAction.group([finishAttack, spinLoop])
                enemyNode.runAction(moveSequence, completionHandler: {
                    enemyNode.removeFromParentNode()
                    self.createRandomEnemy()
                })
                if (lives == 3) {
                    lives = lives-1
                    let blackSmokeSystem = SCNParticleSystem(named: "BlackSmoke", inDirectory: nil)
                    carNode.addParticleSystem(blackSmokeSystem!)
                } else if (lives == 2) {
                    lives = lives-1
                    let fireSystem = SCNParticleSystem(named: "Fire", inDirectory: nil)
                    carNode.removeAllParticleSystems()
                    carNode.addParticleSystem(fireSystem!)
                } else {
                    score = 0
                    lives = 3
                    carNode.removeAllParticleSystems()
                }
            }
        } else if (contact.nodeA == wallNode || contact.nodeB == wallNode) {
            let enemyNode = contact.nodeA == wallNode ? contact.nodeB : contact.nodeA
            if !enemyNode.paused {
                enemyNode.paused = true
                enemyNode.removeFromParentNode()
                self.createRandomEnemy()
                score += 1
                text.string = String(format: "Score: %d", score)
            }
        }
    }
    
    func createWall () {
        let wallGeometry = SCNBox(width: 200, height: 3, length: 200, chamferRadius: 0)
        wallNode = SCNNode(geometry:wallGeometry)
        let wallShape = SCNPhysicsShape(geometry: wallGeometry, options: nil)
        let wallBody = SCNPhysicsBody(type: .Kinematic, shape: wallShape)
        wallNode.physicsBody = wallBody
        wallBody.categoryBitMask = WallCategory
        wallBody.contactTestBitMask = EnemyCategory
        wallBody.collisionBitMask = EnemyCategory
        wallNode.position = SCNVector3(0,-30,50)
        scene.rootNode.addChildNode(wallNode)
    }
    
    func createRandomEnemy () {
        
        let redMaterial = SCNMaterial()
        redMaterial.reflective.contents = UIColor.redColor()
        redMaterial.diffuse.contents = UIColor.lightGrayColor()
        
        let enemyBox = SCNBox(width: 3, height: CGFloat(arc4random_uniform(5)+4), length: 1, chamferRadius: 1.0)
        enemyBox.materials = [redMaterial]
        let enemyNode = SCNNode(geometry: enemyBox)
        
        let enemyShape = SCNPhysicsShape(geometry: enemyBox, options: nil)
        let enemyBody = SCNPhysicsBody(type: .Dynamic, shape: enemyShape)
        enemyBody.restitution = 0.2
        enemyBody.velocity = SCNVector3Make(0, -50, 0)
        enemyNode.physicsBody = enemyBody
        
        enemyBody.categoryBitMask = EnemyCategory
        enemyBody.contactTestBitMask = CarCategory
        enemyBody.collisionBitMask = EnemyCategory | CarCategory
        
        enemyNode.position = SCNVector3(CGFloat(Double.init(arc4random_uniform(4))*5-7.5),100,0.5)
        scene.rootNode.addChildNode(enemyNode)
    }
    
    func createScore(){
        text = SCNText(string:String(format: "Score: %d", score), extrusionDepth: 1)
        text.font = UIFont (name: "Arial", size: 3)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.whiteColor()
        text.materials = [material]
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(-5,20,5)
        textNode.eulerAngles = SCNVector3Make(1,0,0)
        scene.rootNode.addChildNode(textNode)
    }
    
    func createCar() {
        let greenMaterial = SCNMaterial()
        greenMaterial.reflective.contents = UIColor.greenColor()
        greenMaterial.diffuse.contents = UIColor.lightGrayColor()
        let carBox = SCNBox(width: 2, height: 3, length: 1, chamferRadius: 0.1)
        carBox.materials = [greenMaterial]
        carNode = SCNNode(geometry: carBox)
        let carShape = SCNPhysicsShape(geometry: carBox, options: nil)
        let carBody = SCNPhysicsBody(type: .Kinematic, shape: carShape)
        carNode.physicsBody = carBody
        carBody.categoryBitMask = CarCategory
        carBody.contactTestBitMask = EnemyCategory
        carBody.collisionBitMask = EnemyCategory
        carNode.position = SCNVector3(-2.5,-7,0.5)
        scene.rootNode.addChildNode(carNode)
        
        let particleSystem = SCNParticleSystem(named: "SmokeParticles", inDirectory: nil)
        let exausterNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 1))
        exausterNode.position = SCNVector3(0,-1.5,-0.2)
        exausterNode.addParticleSystem(particleSystem!)
        carNode.addChildNode(exausterNode)
    }
    
    func createSideWalks() {
        for i in -20...100 {
            if i%5==0 {
                let sidewalkMaterial = SCNMaterial()
                sidewalkMaterial.diffuse.contents = UIColor.lightGrayColor()
                let leftSidewalk = SCNBox(width: 4, height: 4.9, length: 0.5, chamferRadius:0)
                let rightSidewalk = SCNBox(width: 4, height: 4.9, length: 0.5, chamferRadius:0)
                leftSidewalk.materials = [sidewalkMaterial]
                rightSidewalk.materials = [sidewalkMaterial]
                let leftSidewalkNode = SCNNode(geometry: leftSidewalk)
                let rightSidewalkNode = SCNNode(geometry: rightSidewalk)
                leftSidewalkNode.position = SCNVector3Make(12,Float.init(i),0.25)
                rightSidewalkNode.position = SCNVector3Make(-12,Float.init(i),0.25)
                scene.rootNode.addChildNode(rightSidewalkNode)
                scene.rootNode.addChildNode(leftSidewalkNode)
                let moveDown = SCNAction.moveByX(0, y: -5, z: 0, duration: 0.1)
                let moveUp = SCNAction.moveByX(0, y: 5, z: 0, duration: 0)
                let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
                leftSidewalkNode.runAction(moveLoop)
                rightSidewalkNode.runAction(moveLoop)
            }
        }
    }
    
    func createLights() {
        for i in 0...60 {
            if i%30==0 {
                let lightPostMaterial = SCNMaterial()
                lightPostMaterial.diffuse.contents = UIColor.blackColor()
                let lightGeometry = SCNBox(width: 0.2, height: 0.2, length: 10, chamferRadius:1)
                lightGeometry.materials = [lightPostMaterial]
                let lightNode = SCNNode(geometry: lightGeometry)
                
                lightNode.position = SCNVector3Make(13,Float.init(i),5)
                scene.rootNode.addChildNode(lightNode)
                let moveDown = SCNAction.moveByX(0, y: -30, z: 0, duration: 0.6)
                let moveUp = SCNAction.moveByX(0, y: 30, z: 0, duration: 0)
                let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
                lightNode.runAction(moveLoop)
                
                
                let spotLight = SCNLight()
                spotLight.type = SCNLightTypeSpot
//                spotLight.castsShadow = true
                spotLight.spotInnerAngle = 70.0
                spotLight.spotOuterAngle = 160.0
                spotLight.zFar = 20
                let light = SCNNode()
                light.light = spotLight
                light.position = SCNVector3(x: 0, y: 0, z: 5)
                lightNode.addChildNode(light)
            }
        }
    }
    
    func createLanes () {
        for i in -20...100 {
            let laneMaterial = SCNMaterial()
            if i%5==0 || i%5==1 {
                laneMaterial.diffuse.contents = UIColor.clearColor()
            } else {
                laneMaterial.diffuse.contents = UIColor.yellowColor()
            }
            let middleLane = SCNBox(width: 0.2, height: 1, length: 0.1, chamferRadius:0)
            middleLane.materials = [laneMaterial]
            let middleNode = SCNNode(geometry: middleLane)
            
            let leftLane = SCNBox(width: 0.2, height: 1, length: 0.1, chamferRadius: 0)
            leftLane.materials = [laneMaterial]
            let leftNode = SCNNode(geometry: leftLane)
            
            let rightLane = SCNBox(width: 0.2, height: 1, length: 0.1, chamferRadius: 0)
            rightLane.materials = [laneMaterial]
            let rightNode = SCNNode(geometry: rightLane)
            
            middleNode.position = SCNVector3(0,i,0)
            leftNode.position = SCNVector3(-5,i,0)
            rightNode.position = SCNVector3(5,i,0)
            
            scene.rootNode.addChildNode(middleNode)
            scene.rootNode.addChildNode(leftNode)
            scene.rootNode.addChildNode(rightNode)
            
            let moveDown = SCNAction.moveByX(0, y: -5, z: 0, duration: 0.1)
            let moveUp = SCNAction.moveByX(0, y: 5, z: 0, duration: 0)
            let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
            middleNode.runAction(moveLoop)
            rightNode.runAction(moveLoop)
            leftNode.runAction(moveLoop)
        }
    }
    
    func createGround () {
        let groundGeometry = SCNPlane(width: 150, height: 150)
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.darkGrayColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        ground.position = SCNVector3(0,50,0)
        
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        let groundBody = SCNPhysicsBody(type: .Kinematic, shape: groundShape)
        ground.physicsBody = groundBody
        
        let gravityField = SCNPhysicsField.linearGravityField()
        gravityField.strength = 10
        ground.physicsField = gravityField
        
        scene.rootNode.addChildNode(ground)
    }
    
    func createCamera () {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: -18, z: 25)
        cameraNode.camera?.aperture = 1/2
        scene.fogStartDistance = 20
        scene.fogEndDistance = 80
        scene.fogDensityExponent = 1
        scene.fogColor = UIColor.lightGrayColor()
        cameraNode.eulerAngles.x = Float.init(0.8)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .Portrait
        } else {
            return .Portrait
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
