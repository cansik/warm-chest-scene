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
    //uniform vec2 u_resolution = vec2(1.0, 1.0);
    uniform float amplitude = 2.0;
    uniform float yScale = 0.05;

    // 2D Random
    float random (in vec2 st) {
        return fract(sin(dot(st.xy,
                             vec2(12.9898,78.233)))
                     * 43758.5453123);
    }

    // 2D Noise based on Morgan McGuire @morgan3d
    // https://www.shadertoy.com/view/4dS3Wd
    float noise (in vec2 st) {
        vec2 i = floor(st);
        vec2 f = fract(st);

        // Four corners in 2D of a tile
        float a = random(i);
        float b = random(i + vec2(1.0, 0.0));
        float c = random(i + vec2(0.0, 1.0));
        float d = random(i + vec2(1.0, 1.0));

        // Smooth Interpolation

        // Cubic Hermine Curve.  Same as SmoothStep()
        vec2 u = f*f*(3.0-2.0*f);
        // u = smoothstep(0.,1.,f);

        // Mix 4 coorners percentages
        return mix(a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
    }
    
    #pragma body
    // apply y scale
    _geometry.position.y = mix(0.0, _geometry.position.y, yScale);
    //_geometry.position += (amplitude * _geometry.position.y * _geometry.position.x) * sin(3.0 * u_time);
    
    // apply ground noise
    vec2 st = _geometry.position.xy; // / u_resolution.xy;
    vec2 pos = vec2(st*1.0);

    // Use the noise function
    //float n = noise(pos);
    float n = random(pos);

    _geometry.position.y += n * sin(u_time);
    """
    
    let fragmentShader =
    """
    uniform float mixLevel = 0.0;
    
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
