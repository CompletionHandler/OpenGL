//
//  ViewController.m
//  OpenGL（变换）
//
//  Created by cy on 20/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTexttureTranform. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,assign) GLint program;
@property (nonatomic,assign) GLint texture0;
@property (nonatomic,assign) GLint texture1;
@property (nonatomic,assign) GLKMatrix4 matrix4;
@property (nonatomic,assign) GLfloat currentRoate;
@end
/**
 注意glGenBuffers - glBindBuffer && glGenTextures - glBindTexture的对应关系，不然会导致纹理绘制黑屏。
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
    GLint logLength;
    glGetProgramiv(self.program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar infoLog[logLength];
        glGetProgramInfoLog(self.program, logLength, NULL, infoLog);
        NSLog(@"%s: %s", __func__, infoLog);
    }
    
    self.texture0 = [self setTextureWithImageName:@"beetle.png"];
    self.texture1 = [self setTextureWithImageName:@"leaves.gif"];
    
    GLfloat vertexArray[] = {
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上 0
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下 1
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,  0.0f, 0.0f,   // 左下 2
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,  0.0f, 1.0f    // 左上 3
    };
    
    GLint elementArray[] = {
        0, 1, 2,
        0, 2, 3
    };
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elementArray), elementArray, GL_STATIC_DRAW);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    GLint aPosition = glGetAttribLocation(self.program, "aPosition");
    glEnableVertexAttribArray(aPosition);
    glVertexAttribPointer(aPosition, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), 0);
    
    GLint aTextCoord = glGetAttribLocation(self.program, "aTextCoord");
    glEnableVertexAttribArray(aTextCoord);
    glVertexAttribPointer(aTextCoord, 2, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), (GLfloat *)NULL + 6);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture0);
    GLint textureColor0 = glGetUniformLocation(self.program, "texture0");
    glUniform1i(textureColor0, 0);
    glUseProgram(self.program);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture1);
    GLint textureColor1 = glGetUniformLocation(self.program, "texture1");
    glUniform1i(textureColor1, 1);
    glUseProgram(self.program);
}

- (void)update{
    
    GLKMatrix4 baseMatri4 = GLKMatrix4MakeTranslation(0.5f, -0.5f, 0.0f);
    baseMatri4 = GLKMatrix4Rotate(baseMatri4, self.currentRoate*(M_PI/90), 0.0f, 0.0f, 1.0f);
    self.matrix4 = baseMatri4;
    self.currentRoate += self.timeSinceLastUpdate * 0.5;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLint tranform = glGetUniformLocation(self.program, "tranform");
    glUniformMatrix4fv(tranform, 1, 0, self.matrix4.m);
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

- (GLuint)setTextureWithImageName:(NSString *)name{
    
    CGImageRef imageRef = [[UIImage imageNamed:name] CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    float fWidth = width;
    float fHeight = height;
    
    NSMutableData *mutableData = [NSMutableData dataWithLength:4*fWidth*fHeight];
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate([mutableData mutableBytes], width, height, 8, 4*width, spaceRef, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, fWidth, fHeight), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(spaceRef);
    
    GLuint textureBuffer;
    glGenTextures(1, &textureBuffer);
    glBindTexture(GL_TEXTURE_2D, textureBuffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fWidth, fHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, [mutableData bytes]);
    
    return textureBuffer;
}

- (GLint)loadShader{
    GLuint verShader, fraShader;
    GLint program = glCreateProgram();
    
    NSString *verPath = [[NSBundle mainBundle] pathForResource:@"Shader.vsh" ofType:nil];
    NSString *fraPath = [[NSBundle mainBundle] pathForResource:@"Shader.fsh" ofType:nil];
    //注意type要设置对，不然可能编译shader的时候会出错
    [self compileShader:&verShader type:GL_VERTEX_SHADER filePath:verPath];
    [self compileShader:&fraShader type:GL_FRAGMENT_SHADER filePath:fraPath];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fraShader);
    glDeleteShader(verShader);
    glDeleteShader(fraShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath{
    
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *souce = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &souce, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar info[logLength];
        glGetShaderInfoLog(*shader, logLength, NULL, info);
        NSLog(@"%s: %s", __func__, info);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
