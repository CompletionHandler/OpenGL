//
//  ViewController.m
//  OpenGL（纹理GLKit）
//
//  Created by cy on 19/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTexttureGLK. All rights reserved.
//

#import "ViewController.h"

GLfloat vertexArray[] = {
    -1.0f, -0.67f, 0.0f, 0.0f, 0.0f,  // first triangle
    1.0f, -0.67f, 0.0f, 1.0f, 0.0f,
    -1.0f,  0.67f, 0.0f, 0.0f, 1.0f,
    1.0f, -0.67f, 0.0f, 1.0f, 0.0f,  // second triangle
    -1.0f, 0.67f, 0.0f, 0.0f, 1.0f,
    1.0f, 0.67f, 0.0f, 1.0f, 1.0f
};

@interface ViewController ()
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) EAGLContext *context;
@property (nonatomic,strong) GLKTextureInfo *textureInfo1;
@property (nonatomic,strong) GLKTextureInfo *textureInfo2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glkView = (GLKView *)self.view;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.baseEffect = [GLKBaseEffect new];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 5*sizeof(GL_FLOAT), (GLfloat *) NULL + 3);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    CGImageRef leavesImage = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    CGImageRef beetleImage = [[UIImage imageNamed:@"beetle.png"] CGImage];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:leavesImage options:@{GLKTextureLoaderOriginBottomLeft: [NSNumber numberWithBool:NO]} error:nil];
    self.textureInfo2 = [GLKTextureLoader textureWithCGImage:beetleImage options:@{GLKTextureLoaderOriginBottomLeft: [NSNumber numberWithBool:NO]} error:nil];
    /**
     通过glEnable来开启混合，通过glBlendFunc来设置混合的方式。
     sourceFactor指定了当前的片元的颜色颜素是如何参与混合的。
     destinationFactor指定了目标缓存帧的颜色元素如何影响缓存。
     
     GL_SRC_ALPHA:源片元的透明度颜色挨个于其他片元颜色颜素相乘
     GL_ONE_MINUS_SRC_ALPHA:让缓存帧的透明度元素和缓存帧内正被更新的像素元素相乘。
     */
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    self.baseEffect.texture2d0.name = self.textureInfo1.name;
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    self.baseEffect.texture2d0.name = self.textureInfo2.name;
    self.baseEffect.texture2d0.target = self.textureInfo2.target;
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
