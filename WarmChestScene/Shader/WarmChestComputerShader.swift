//
//  WarmChestComputerShader.swift
//  WarmChestScene
//
//  Created by Florian Bruggisser on 28.11.18.
//  Copyright © 2018 Florian Bruggisser. All rights reserved.
//

import Foundation
import SceneKit

class WarmChestComputerShader
{
    var material : SCNMaterial
    
    let vertexShader =
    """
    uniform float amplitude = 0.1;
            
    _geometry.position += (amplitude *_geometry.position.y * _geometry.position.x) * sin(1.0 * u_time);
    """
    
    let fragmentShader =
    """
    uniform float mixLevel = 0.0;
            
    vec3 gray = vec3(dot(vec3(0.3, 0.59, 0.11), _output.color.rgb));
    _output.color = mix(_output.color, vec4(gray, 1.0), sin(u_time));
    """
    
    public init(material : SCNMaterial) {
        self.material = material
    }
    
    public func attachShader()
    {
        material.shaderModifiers = [
            SCNShaderModifierEntryPoint.geometry: vertexShader,
            SCNShaderModifierEntryPoint.fragment: fragmentShader
        ];
    }
    
    public func setMixLevel(value : Float)
    {
        material.setValue(value, forKey: "mixLevel")
    }
}
