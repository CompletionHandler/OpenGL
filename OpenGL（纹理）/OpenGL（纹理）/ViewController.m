//
//  ViewController.m
//  OpenGL（纹理）
//
//  Created by cy on 18/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTextture. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,assign) GLint program;
@property (nonatomic,assign) GLint texture0;
@property (nonatomic,assign) GLint texture1;
@end
/**
 注意glGenBuffers-glBindBuffer && glGenTextures - glBindTexture的对应关系，不然会导致纹理绘制黑屏。
 */

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *glkView = (GLKView *)self.view;
    EAGLContext *context =[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.context = context;
    [EAGLContext setCurrentContext:glkView.context];
    
    self.program = [self loadShader];
    glLinkProgram(self.program);
    GLint success;
    glGetProgramiv(self.program, GL_LINK_STATUS, &success);
    
    if (success == GL_FALSE) {
        GLchar info[256];
        glGetProgramInfoLog(self.program, 256, NULL, info);
        NSLog(@"%s: %s", __func__ , info);
        return;
    }
    
    self.texture0 = [self setTextureWithImage:@"leaves.gif"];
    self.texture1 = [self setTextureWithImage:@"beetle.png"];
    
    GLfloat vertexArray[] = {
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上 0
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下 1
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,  0.0f, 0.0f,   // 左下 2
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,  0.0f, 1.0f    // 左上 3
    };
    
    GLuint eleArray[] = {
        0, 1, 3,
        3, 1, 2
    };
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(eleArray), eleArray, GL_STATIC_DRAW);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    GLint aPosition = glGetAttribLocation(self.program, "aPosition");
    glEnableVertexAttribArray(aPosition);
    glVertexAttribPointer(aPosition, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), 0);
    
    GLint aColor = glGetAttribLocation(self.program, "aColor");
    glEnableVertexAttribArray(aColor);
    glVertexAttribPointer(aColor, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), (float *)NULL+3);
    
    GLint aTexturePosition = glGetAttribLocation(self.program, "aTexturePosition");
    glEnableVertexAttribArray(aTexturePosition);
    glVertexAttribPointer(aTexturePosition, 2, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), (GLfloat *)NULL + 6);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture0);
    GLint texture0 = glGetUniformLocation(self.program, "ourTexture1");
    glUniform1i(texture0, 0);
    glUseProgram(self.program);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture1);
    GLint texture1 = glGetUniformLocation(self.program, "ourTexture2");
    glUniform1i(texture1, 1);
    glUseProgram(self.program);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

- (GLuint) setTextureWithImage:(NSString *)imageName{
    CGImageRef imageRef = [[UIImage imageNamed:imageName] CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    float fWidth = width;
    float fHeight = height;
    
    NSMutableData *mutableData = [NSMutableData dataWithLength:4*width*height];
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate([mutableData mutableBytes], width, height, 8, 4*width, spaceRef, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, fWidth, fHeight), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(spaceRef);
    
    GLuint textBO;
    glGenTextures(1, &textBO);
    glBindTexture(GL_TEXTURE_2D, textBO);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fWidth, fHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, [mutableData bytes]);
    return textBO;
}

- (GLint)loadShader{
    GLuint verShader, fraShader;
    GLint program = glCreateProgram();
    
    NSString *verPath = [[NSBundle mainBundle] pathForResource:@"Shader.vsh" ofType:nil];
    NSString *fraPath = [[NSBundle mainBundle] pathForResource:@"Shader.fsh" ofType:nil];
    
    [self complimeShader:&verShader type:GL_VERTEX_SHADER filePath:verPath];
    [self complimeShader:&fraShader type:GL_FRAGMENT_SHADER filePath:fraPath];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fraShader);
    glDeleteShader(verShader);
    glDeleteShader(fraShader);
    
    return program;
}

- (void)complimeShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath{
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    GLchar shaderInfo[logLength];
    if (logLength > 0) {
        glGetShaderInfoLog(*shader, logLength, NULL, shaderInfo);
        NSLog(@"%s", shaderInfo);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
