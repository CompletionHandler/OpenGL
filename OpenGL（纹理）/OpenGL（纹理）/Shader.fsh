//
//  Shader.fsh
//  OpenGL（纹理）
//
//  Created by cy on 18/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTextture. All rights reserved.
//

varying lowp vec3 textureColor;
varying lowp vec2 texturePosition;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

void main(){
    
    lowp vec4 color0 = texture2D(ourTexture1, texturePosition);
    lowp vec4 color1 = texture2D(ourTexture2, texturePosition);
    gl_FragColor = mix(color0, color1, 0.5)*vec4(textureColor, 1.0);
}
