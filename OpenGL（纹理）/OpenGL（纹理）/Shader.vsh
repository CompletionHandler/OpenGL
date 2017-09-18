//
//  Shader.vsh
//  OpenGL（纹理）
//
//  Created by cy on 18/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTextture. All rights reserved.
//

attribute vec3 aPosition;
attribute vec3 aColor;
attribute vec2 aTexturePosition;

varying lowp vec3 textureColor;
varying lowp vec2 texturePosition;

void main(){
    gl_Position = vec4(aPosition, 1.0);
    textureColor = aColor;
    //由于OpenGL的坐标y轴原点是在底部，而图片的y轴的原点在顶部，需要置换一下不然纹理会颠倒
    texturePosition = vec2(aTexturePosition.x, 1.0-aTexturePosition.y);
}
