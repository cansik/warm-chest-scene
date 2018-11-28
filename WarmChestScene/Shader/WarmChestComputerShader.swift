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
    uniform float scaleY = 0.05;

    uniform float noiseX = 0.01;
    uniform float noiseY = 0.01;
    
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
    _geometry.position.y = mix(0.0, _geometry.position.y, scaleY);
    
    // apply ground noise x
    float dx = random(_geometry.position.xz);
    float phaseX = random(_geometry.position.yz);
    _geometry.position.x += noiseX * dx * noiseSine(u_time, PI, phaseX);

    // apply ground noise y
    float dy = random(_geometry.position.xy);
    float phaseY = random(_geometry.position.xz);
    _geometry.position.y += noiseY * dy * noiseSine(u_time, PI, phaseY);
    """
    
    let fragmentShader =
    """
    uniform float saturation = 0.0;
    uniform float overlayColorLevel = 1.0;
    uniform vec3 overlayColor = vec3(0.0, 0.0, 0.0);

    #pragma body
    // apply gray
    vec3 gray = vec3(dot(vec3(0.3, 0.59, 0.11), _output.color.rgb));
    _output.color = mix(vec4(gray, 1.0), _output.color, saturation);

    // fadeout level
    _output.color = mix(_output.color, vec4(overlayColor, 1.0), overlayColorLevel);
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
    
    public func setSaturation(value : Float)
    {
        material.setValue(value, forKey: "saturation")
    }
    
    public func setOverlayColorLevel(value : Float)
    {
        material.setValue(value, forKey: "overlayColorLevel")
    }
    
    public func setOverlayColor(value : SCNVector3)
    {
        material.setValue(value, forKey: "overlayColor")
    }
    
    public func setScaleY(value : Float)
    {
        material.setValue(value, forKey: "scaleY")
    }
    
    public func setNoiseY(value : Float)
    {
        material.setValue(value, forKey: "noiseY")
    }
    
    public func setNoiseX(value : Float)
    {
        material.setValue(value, forKey: "noiseX")
    }
}
