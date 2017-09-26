//
//  ObjectShader.vsh
//  OpenGL（材质）
//
//  Created by cy on 26/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTexture. All rights reserved.
//

attribute vec3 aPosition;
attribute vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec3 normal;
varying lowp vec3 fragPos;

void main(){
    
    gl_Position = projection * view * model * vec4(aPosition, 1.0);
    fragPos = vec3(model * vec4(aPosition, 1.0));
    normal = normalize(aNormal);
}
