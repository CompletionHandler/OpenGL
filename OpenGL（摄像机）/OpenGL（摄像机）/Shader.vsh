//
//  Shader.vsh
//  OpenGL（摄像机）
//
//  Created by cy on 21/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLCamera. All rights reserved.
//

attribute vec3 aPosition;
attribute vec2 aTextCoord;
//
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec2 textCoord;

void main(){
    gl_Position = projection * view * model * vec4(aPosition, 1.0);
    //    gl_Position = vec4(aPosition, 1.0);
    textCoord = vec2(aTextCoord.x, 1.0 - aTextCoord.y);
}
