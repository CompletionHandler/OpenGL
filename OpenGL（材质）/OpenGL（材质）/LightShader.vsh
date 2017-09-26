//
//  LightShader.vsh
//  OpenGL（材质）
//
//  Created by cy on 26/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTexture. All rights reserved.
//

attribute lowp vec3 aPosition;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main(){
    gl_Position = projection * view * model * vec4(aPosition, 1.0);
}
