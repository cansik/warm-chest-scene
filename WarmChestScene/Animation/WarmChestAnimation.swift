//
//  BaseAnimation.swift
//  WarmChestScene
//
//  Created by Florian Bruggisser on 28.11.18.
//  Copyright © 2018 Florian Bruggisser. All rights reserved.
//

import Foundation
import SceneKit
import AVKit

class WarmChestAnimation
{
    let scene : SCNScene
    let cameraNode : SCNNode
    let computeShader : WarmChestComputerShader
    let pointCloud : SCNNode
    
    let colorAnimationNode = SCNNode()
    let scaleYAnimationNode = SCNNode()
    let noiseAnimationNode = SCNNode()
    let noiseAnimationNode2 = SCNNode()
    
    var running = false
    
    init(scene : SCNScene, cameraNode : SCNNode, computeShader : WarmChestComputerShader, pointCloud : SCNNode) {
        self.scene = scene
        self.cameraNode = cameraNode
        self.computeShader = computeShader
        self.pointCloud = pointCloud
    }
    
    public func setupAnimation()
    {
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 10)
    }
    
    public func runAnimation() {
        // setup camera movement
        setupCameraMovement()
        
        // setup pointcloud animation
        setupPointCloudAnimation()
        
        // setup audio
        setupAudio()
        
        running = true
    }
    
    func setupCameraMovement()
    {
        // animate camera to move forward
        cameraNode.runAction(
            SCNAction.repeatForever(
                SCNAction.moveBy(x: 0.0, y: 0.0, z: -0.1, duration: 1.0)
        ))
        
        // animate rotate camera
         cameraNode.runAction(
             SCNAction.sequence([
                SCNAction.wait(duration: 45.4),
                SCNAction.moveBy(x: 0.0, y: -0.5, z: 0.0, duration: 0.1),
                SCNAction.wait(duration: 14.5),
                SCNAction.rotateBy(x: 0.0, y: 0.0, z: 2 * 3.14, duration: 30.0),
             ])
         )
    }
    
    func setupPointCloudAnimation()
    {
        // color
        let fadeInTime = TimeInterval(20)
        let mixChangeTime = TimeInterval(23)
        let flashTime = TimeInterval(0.3)
        let fadeOutTime = TimeInterval(5)
        
        let flashAnimation = SCNAction.customAction(duration: flashTime, action: { (node, value) in
            let normalizedTime = Float(Double(value) / flashTime);
            self.computeShader.setOverlayColor(value: SCNVector3(1.0, 1.0, 1.0))
            self.computeShader.setOverlayColorLevel(value: lerp(normalizedTime, min: 1.0, max: 0.0))
            self.changePointSize(size: lerp(normalizedTime, min: 20, max: 7))
        })
        
        scene.rootNode.addChildNode(colorAnimationNode)
        colorAnimationNode.runAction(
            SCNAction.sequence([
                SCNAction.customAction(duration: fadeInTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / fadeInTime);
                    self.computeShader.setOverlayColor(value: SCNVector3(0.0, 0.0, 0.0))
                    self.computeShader.setOverlayColorLevel(value: lerp(normalizedTime, min: 1.0, max: 0.0))
                }),
                SCNAction.wait(duration: 1),
                SCNAction.customAction(duration: mixChangeTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / mixChangeTime);
                    self.computeShader.setSaturation(value: lerp(normalizedTime, min: 0.0, max: 1.0))
                }),
                SCNAction.wait(duration: 16),
                flashAnimation,
                SCNAction.wait(duration: 15),
                SCNAction.customAction(duration: fadeOutTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / fadeOutTime);
                    self.computeShader.setOverlayColor(value: SCNVector3(0.0, 0.0, 0.0))
                    self.computeShader.setOverlayColorLevel(value: lerp(normalizedTime, min: 0.0, max: 1.0))
                }),
                ]))
        
        // scale Y
        let scaleGrowTime = TimeInterval(0.4)
        let finalGrowTime = TimeInterval(50)
        
        scene.rootNode.addChildNode(scaleYAnimationNode)
        scaleYAnimationNode.runAction(
            SCNAction.sequence([
                SCNAction.wait(duration: 44.8),
                SCNAction.customAction(duration: scaleGrowTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / scaleGrowTime);
                    self.computeShader.setScaleY(value: lerp(normalizedTime, min: 0.05, max: 1.0))
                }),
                SCNAction.wait(duration: 30),
                SCNAction.customAction(duration: finalGrowTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / finalGrowTime);
                    self.computeShader.setScaleY(value: lerp(normalizedTime, min: 1.0, max: 4.0))
                }),
                ]))
        
        // noise
        let noiseGrowTime = TimeInterval(23.5)
        let noiseShrinkTime = TimeInterval(0.5)
        let noiseFadeOutTime = TimeInterval(20)
        
        scene.rootNode.addChildNode(noiseAnimationNode)
        noiseAnimationNode.runAction(
            SCNAction.sequence([
                SCNAction.wait(duration: 21.5),
                SCNAction.customAction(duration: noiseGrowTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / noiseGrowTime);
                    self.computeShader.setNoiseY(value: lerp(normalizedTime, min: 0.01, max: 1.0))
                }),
                SCNAction.customAction(duration: noiseShrinkTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / noiseShrinkTime);
                    self.computeShader.setNoiseY(value: lerp(normalizedTime, min: 1.0, max: 0.001))
                    self.computeShader.setNoiseX(value: lerp(normalizedTime, min: 0.01, max: 0.003))
                }),
                SCNAction.wait(duration: 30),
                SCNAction.customAction(duration: noiseFadeOutTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / noiseFadeOutTime);
                    self.computeShader.setNoiseY(value: lerp(normalizedTime, min: 0.001, max: 0.00))
                    self.computeShader.setNoiseX(value: lerp(normalizedTime, min: 0.003, max: 0.00))
                    self.changePointSize(size: lerp(normalizedTime, min: 7, max: 0.1))
                })
                ]))
        
        
        // second noise
    let noiseXShrinkTime = TimeInterval(8)
    
        scene.rootNode.addChildNode(noiseAnimationNode2)
        noiseAnimationNode2.runAction(
            SCNAction.sequence([
                SCNAction.wait(duration: 37),
                SCNAction.customAction(duration: noiseXShrinkTime, action: { (node, value) in
                    let normalizedTime = Float(Double(value) / noiseXShrinkTime);
                    self.computeShader.setNoiseX(value: lerp(normalizedTime, min: 0.01, max: 0.001))
                })
        ]))
    }
    
    func setupAudio()
    {
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "Yndusik - Warm Chest_44_16_Mark@Calyx_M220918.wav")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        
        audioNode.addAudioPlayer(audioPlayer)
        
        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
        audioNode.runAction(play)
        scene.rootNode.addChildNode(audioNode)
        
        let musicFadeOutTime = TimeInterval(10)
        
        audioNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 80),
            SCNAction.customAction(duration: musicFadeOutTime, action: { (node, value) in
                let normalizedTime = Float(Double(value) / musicFadeOutTime);
                if let mixer = audioPlayer.audioNode as? AVAudioMixerNode {
                    mixer.volume = lerp(normalizedTime, min: 1.0, max: 0.0)
                }
            }),
        ]))
    }
    
    func changePointSize(size : Float)
    {
        self.pointCloud.geometry!.elements.forEach { (e : SCNGeometryElement) in
            e.maximumPointScreenSpaceRadius = CGFloat(size)
            e.pointSize = CGFloat(size)
        }
    }
}
