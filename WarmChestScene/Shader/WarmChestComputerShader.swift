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
    uniform float amplitude = 2.0;
    uniform float yScale = 0.05;
    uniform float PI = 3.1415926535897932384626433832795;

    // 2D Random
    float random (in vec2 st) {
        return fract(sin(dot(st.xy,
                             vec2(12.9898,78.233)))
                     * 43758.5453123);
    }

    float noiseSine(float x, float PI, float phase) {
        return 0.5 * (1 + sin(2 * PI * x - (PI / phase)));
    }

    #pragma body
    // apply y scale
    _geometry.position.y = mix(0.0, _geometry.position.y, yScale);
    
    // apply ground noise
    float dy = random(_geometry.position.xy);
    float phaseY = random(_geometry.position.xz);
    _geometry.position.y += 0.02 * dy * noiseSine(u_time, PI, phaseY);

    float dx = random(_geometry.position.xz);
    float phaseX = random(_geometry.position.yz);
    _geometry.position.x += 0.02 * dx * noiseSine(u_time, PI, phaseX);
    """
    
    let fragmentShader =
    """
    uniform float mixLevel = 1.0;
    
    #pragma body
    vec3 gray = vec3(dot(vec3(0.3, 0.59, 0.11), _output.color.rgb));
    _output.color = mix(_output.color, vec4(gray, 1.0), sin(mixLevel));
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
    
    public func setYScale(value : Float)
    {
        material.setValue(value, forKey: "yScale")
    }
    
    
}
