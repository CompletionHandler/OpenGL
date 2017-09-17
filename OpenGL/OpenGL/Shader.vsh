//
//  Shader.vsh
//  OpenGL
//
//  Created by cy on 17/09/2017.
//  Copyright © 2017 com.jiemu.OpenGL. All rights reserved.
//

attribute vec4 aPosition;

varying lowp vec4 verxtureColor;

void main(){
    gl_Position = aPosition;
    verxtureColor = vec4(0.0, 0.0, 0.0, 1.0);
}
