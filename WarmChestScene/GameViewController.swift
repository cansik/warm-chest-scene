//
//  GameViewController.swift
//  WarmChestScene
//
//  Created by Florian Bruggisser on 28.11.18.
//  Copyright © 2018 Florian Bruggisser. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    let pc = PointCloud()
    var computeShader = WarmChestComputerShader(material: SCNMaterial())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.005
        
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.gray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // load pointcloud
        let pcs = Bundle.main.paths(forResourcesOfType: "ply", inDirectory: "")
        pc.load(file: pcs[0])
        let cloud = pc.getNode(useColor: true)
        cloud.scale = SCNVector3(10.0, 10.0, 10.0)
        scene.rootNode.addChildNode(cloud)
        
        // animate camera to move forward
        cameraNode.runAction(
            SCNAction.repeatForever(
                SCNAction.moveBy(x: 0.0, y: 0.0, z: -0.1, duration: 1.0)
        ))
        
        // animate rotate camera
        cameraNode.runAction(
            SCNAction.sequence([
                SCNAction.rotateBy(x: 0.0, y: 0.0, z: 3.14, duration: 5.0),
                SCNAction.rotateBy(x: 0.0, y: 0.0, z: -3.14, duration: 5.0)
                ])
        )
        
        // shaders
        let material = cloud.geometry?.firstMaterial!
        computeShader = WarmChestComputerShader(material: material!)
        computeShader.attachShader()
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
