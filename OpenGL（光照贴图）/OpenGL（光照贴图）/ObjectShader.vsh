//
//  ObjectShader.vsh
//  OpenGL（光照贴图）
//
//  Created by cy on 29/09/2017.
//  Copyright © 2017 jiemu. All rights reserved.
//


attribute vec3 aPosition;
attribute vec3 aNormal;
attribute vec2 aTextCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec3 normal;
varying lowp vec3 fragPos;
varying lowp vec2 textCoord;

void main(){
    
    gl_Position = projection * view * model * vec4(aPosition, 1.0);
    fragPos = vec3(model * vec4(aPosition, 1.0));
    normal = normalize(aNormal);
    textCoord = aTextCoord;
}
