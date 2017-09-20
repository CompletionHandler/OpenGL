//
//  Shader.vsh
//  OpenGL（变换）
//
//  Created by cy on 20/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTexttureTranform. All rights reserved.
//

attribute vec3 aPosition;
attribute vec2 aTextCoord;

uniform mat4 tranform;

varying lowp vec2 textCoord;

void main(){
    gl_Position = tranform * vec4(aPosition, 1.0);
    
    textCoord = vec2(aTextCoord.x, 1.0 - aTextCoord.y);
}
