//
//  Shader.fsh
//  OpenGL（摄像机）
//
//  Created by cy on 21/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLCamera. All rights reserved.
//

varying lowp vec2 textCoord;

uniform sampler2D texture0;
uniform sampler2D texture1;

void main(){
    lowp vec4 color0 = texture2D(texture0, textCoord);
    lowp vec4 color1 = texture2D(texture1, textCoord);
    gl_FragColor = mix(color0, color1, 0.5);
}

