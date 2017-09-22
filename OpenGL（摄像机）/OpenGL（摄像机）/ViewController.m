//
//  ViewController.m
//  OpenGL（摄像机）
//
//  Created by cy on 21/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLCamera. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,assign) GLint program;
@property (nonatomic,assign) GLint texture0;
@property (nonatomic,assign) GLint texture1;
@property (nonatomic,assign) GLKMatrix4 matrix4;
@property (nonatomic,assign) GLfloat currentRoate;
@end

static const GLfloat cubeArray[] = {
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};

typedef struct {
    GLKVector3  positionCoords;
}CubeVertex;

static const CubeVertex cubePosition[] = {
    {0.0f,  0.0f,  0.0f},
    {2.0f,  5.0f, -15.0f},
    {-1.5f, -2.2f, -2.5f},
    {-3.8f, -2.0f, -12.3f},
    {2.4f, -0.4f, -3.5f},
    {-1.7f,  3.0f, -7.5f},
    {1.3f, -2.0f, -2.5f},
    {1.5f,  2.0f, -2.5f},
    {1.5f,  0.2f, -1.5f},
    {-1.3f,  1.0f, -1.5f},
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *glkView = (GLKView *)self.view;
    EAGLContext *context =[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkView.context = context;
    [EAGLContext setCurrentContext:glkView.context];
    
    glEnable(GL_DEPTH_TEST);
    
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
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeArray), cubeArray, GL_STATIC_DRAW);
    
    GLint aPosition = glGetAttribLocation(self.program, "aPosition");
    glEnableVertexAttribArray(aPosition);
    glVertexAttribPointer(aPosition, 3, GL_FLOAT, GL_FALSE, 5*sizeof(GL_FLOAT), 0);
    
    GLint aTextCoord = glGetAttribLocation(self.program, "aTextCoord");
    glEnableVertexAttribArray(aTextCoord);
    glVertexAttribPointer(aTextCoord, 2, GL_FLOAT, GL_FALSE, 5*sizeof(GL_FLOAT), (GLfloat *)NULL + 3);
    
    glUseProgram(self.program);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture0);
    GLint textureColor0 = glGetUniformLocation(self.program, "texture0");
    glUniform1i(textureColor0, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture1);
    GLint textureColor1 = glGetUniformLocation(self.program, "texture1");
    glUniform1i(textureColor1, 1);
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    GLKMatrix4 proMatrai4 = GLKMatrix4MakePerspective(45 * (M_PI /180), screenWidth/screenHeight, 0.1f, 100.0f);
    GLint projection = glGetUniformLocation(self.program, "projection");
    glUniformMatrix4fv(projection, 1, GL_FALSE, proMatrai4.m);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    float currentTime = CACurrentMediaTime();
    [self setViewMatrixWithTime:currentTime];
    for (int i = 0; i < 10; i++) {
        //设置位移，让各个立方体画在不同的位置
        GLKMatrix4 modelMatrix4 = GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, cubePosition[i].positionCoords);
        
        modelMatrix4 = GLKMatrix4RotateWithVector3(modelMatrix4, currentTime * 20.0f * (M_PI / 180), GLKVector3Make(1.0f, 0.3f, 0.5f));
        GLint model = glGetUniformLocation(self.program, "model");
        glUniformMatrix4fv(model, 1, GL_FALSE, modelMatrix4.m);
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
}

- (void) setViewMatrixWithTime:(float)time{
    GLfloat radius = 10.0f;
    GLfloat camX = sin(time) * radius;
    GLfloat camZ = cos(time) * radius;
    /**
     设置观察区域：将世界坐标转化为观察坐标，实际上就是求的观察视角的三位坐标。首先需要定义观察坐标（观察空间的原点）和目标坐标（观察的方向），然后根据观察坐标求得各纬度。
     z轴正方向： （观察坐标 - 目标坐标）
     x轴正方向：先找一个和z轴方向不平行的向量，使其正交
     GLKVector3CrossProduct(GLKVector3 vectorLeft, GLKVector3 vectorRight)
     y轴正方向：z轴，x轴正交
     
     观察矩阵：
     |Rx  Ry  Rz  0|    |1  0  0  -Px|
     lookAt = |Ux  Uy  Uz  0| *  |0  1  0  -Py|
     |Dx  Dy  Dz  0|    |0  0  1  -Pz|
     |0   0   0   1|    |0  0  0    1|
     
     R-> x轴正方向; U-> y轴正方向; D->z轴正方向; P->观察坐标
     
     构建方式：
     1.按如上步骤构建
     2.使用GLKMatrix4MakeLookAt自动生成：对应参数：观察位置、目标和上向量
     */
    GLKMatrix4 viewMatrai4 = GLKMatrix4MakeLookAt(camX, 0.0f, camZ, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    GLint view = glGetUniformLocation(self.program, "view");
    glUniformMatrix4fv(view, 1, GL_FALSE, viewMatrai4.m);
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
