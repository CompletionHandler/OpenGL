//
//  ViewController.m
//  OpenGL（光照贴图）
//
//  Created by cy on 28/09/2017.
//  Copyright © 2017 jiemu. All rights reserved.
//

#import "ViewController.h"

typedef enum : NSUInteger {
    GLKObjectProgram,
    GLKLightProgram
} GLKProgramType;

@interface ViewController ()
@property (nonatomic,assign) GLint lightProgram;
@property (nonatomic,assign) GLint objectProgram;
@property (nonatomic,assign) GLuint texture0;
@property (nonatomic,assign) GLuint texture1;
@end

static const GLfloat cubeArray[] = {
    // positions          // normals           // texture coords
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
    
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,   0.0f, 0.0f,
    
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
    
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 1.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
    0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f, 1.0f,
    
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f,
    0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
    0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f, 1.0f
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *glkView = (GLKView *)self.view;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.context = context;
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:glkView.context];
    
    [self setUpProgramType:GLKObjectProgram vetexShaderName:@"ObjectShader.vsh" fragShaderName:@"ObjectShader.fsh"];
    [self setUpProgramType:GLKLightProgram vetexShaderName:@"LightShader.vsh" fragShaderName:@"LightShader.fsh"];
    
    glEnable(GL_DEPTH_TEST);
    
    self.texture0 = [self setupTextureWithName:@"container.png"];
    self.texture1 = [self setupTextureWithName:@"container_specular.png"];
    
    GLuint OVBO;
    glGenBuffers(1, &OVBO);
    glBindBuffer(GL_ARRAY_BUFFER, OVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeArray), cubeArray, GL_STATIC_DRAW);
    
    glUseProgram(self.objectProgram);
    glUseProgram(self.lightProgram);
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.7f, 0.7f, 0.7f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    float currentTime = CACurrentMediaTime();
    
    //需要先试用着色器程序
    glUseProgram(self.objectProgram);
    
    GLint objectPosition = glGetAttribLocation(self.objectProgram, "aPosition");
    glVertexAttribPointer(objectPosition, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(objectPosition);
    
    GLint objectNormal = glGetAttribLocation(self.objectProgram, "aNormal");
    glVertexAttribPointer(objectNormal, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), (GLfloat *)NULL+3);
    glEnableVertexAttribArray(objectNormal);
    
    GLint textCoord = glGetAttribLocation(self.objectProgram, "aTextCoord");
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), (GLfloat *)NULL+6);
    glEnableVertexAttribArray(textCoord);
    
    GLint objectModel = glGetUniformLocation(self.objectProgram, "model");
    GLKMatrix4 objectModelMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, currentTime * 50 * (M_PI/180), 0.0f, 0.1f, -0.03f);
    objectModelMatrix = GLKMatrix4Scale(objectModelMatrix, 1.3, 1.3, 1.3);
    glUniformMatrix4fv(objectModel, 1, GL_FALSE, objectModelMatrix.m);
    
    GLint objectView = glGetUniformLocation(self.objectProgram, "view");
    GLKMatrix4 objectViewMatrix = GLKMatrix4MakeLookAt(0.0f, 0.0f, 10.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    glUniformMatrix4fv(objectView, 1, GL_FALSE, objectViewMatrix.m);
    
    GLint objectProjection = glGetUniformLocation(self.objectProgram, "projection");
    GLKMatrix4 objectProjectionMatrix = GLKMatrix4MakePerspective(45*(M_PI/180), screenWidth/screenHeight, 0.01f, 100.0f);
    glUniformMatrix4fv(objectProjection, 1, GL_FALSE, objectProjectionMatrix.m);
    
    GLint objectViewPos = glGetUniformLocation(self.objectProgram, "viewPos");
    glUniform3f(objectViewPos, 0.0f, 0.0f, 3.0f);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture0);
    GLint materialAmbient = glGetUniformLocation(self.objectProgram, "material.ambient");
    glUniform1i(materialAmbient, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture1);
    GLint materialSpecular = glGetUniformLocation(self.objectProgram, "material.specular");
    glUniform1i(materialSpecular, 1);
    
    GLint materialShininess = glGetUniformLocation(self.objectProgram, "material.shininess");
    glUniform1f(materialShininess, 64.0f);
    
    GLKVector3 lightColor = GLKVector3Make(sin(currentTime * 2.0f), sin(currentTime * 1.7f), sin(currentTime * 0.2f));
    
    GLint lightAmbient = glGetUniformLocation(self.objectProgram, "light.ambient");
    glUniform3f(lightAmbient, 0.5f, 0.5f, 0.5f);
    
    GLint lightDiffuse = glGetUniformLocation(self.objectProgram, "light.diffuse");
    glUniform3f(lightDiffuse, 0.2f, 0.2f, 0.2f);
    
    GLint lightSpecular = glGetUniformLocation(self.objectProgram, "light.specular");
    glUniform3f(lightSpecular, 1.0f, 1.0f, 1.0f);
    
    GLint objectLightPos = glGetUniformLocation(self.objectProgram, "light.position");
    glUniform3f(objectLightPos, 1.2f, 0.0f, 5.0f);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glUseProgram(self.lightProgram);
    GLint lightPosition = glGetAttribLocation(self.lightProgram, "aPosition");
    glVertexAttribPointer(lightPosition, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(lightPosition);
    
    GLint lightModel = glGetUniformLocation(self.lightProgram, "model");
    GLKMatrix4 lightModelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 2.3f, 4.4f, -7.0f);
    lightModelMatrix = GLKMatrix4Rotate(lightModelMatrix, 50*(M_PI/180), 1.0f, 0.3f, 0.5f);
    glUniformMatrix4fv(lightModel, 1, GL_FALSE, lightModelMatrix.m);
    
    GLint lightView = glGetUniformLocation(self.lightProgram, "view");
    glUniformMatrix4fv(lightView, 1, GL_FALSE, objectViewMatrix.m);
    
    GLint lightProjection = glGetUniformLocation(self.lightProgram, "projection");
    glUniformMatrix4fv(lightProjection, 1, GL_FALSE, objectProjectionMatrix.m);
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (GLuint)setupTextureWithName:(NSString *)imageName{
    
    CGImageRef imageRef = [[UIImage imageNamed:imageName] CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    float fwidth = width;
    float fheight = height;
    
    NSMutableData *mutableData = [[NSMutableData alloc] initWithLength:4*width*height];
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate([mutableData mutableBytes], width, height, 8, 4*width, spaceRef, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, fwidth, fheight), imageRef);
    
    CGContextRelease(context);
    CGColorSpaceRelease(spaceRef);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fwidth, fheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, [mutableData bytes]);
    
    return texture;
}

- (void)setUpProgramType:(GLKProgramType)type vetexShaderName:(NSString *)vextexName fragShaderName:(NSString *)fragName{
    GLint program = [self loadProgramWithVetexShaderName:vextexName fragShaderName:fragName];
    
    GLint infoLenght;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLenght);
    
    if (infoLenght > 0) {
        GLchar info[infoLenght];
        glGetProgramInfoLog(program, infoLenght, NULL, info);
        NSLog(@"%s: %s", __func__, info);
    }
    
    switch (type) {
        case GLKObjectProgram:
            self.objectProgram = program;
            glLinkProgram(self.objectProgram);
            break;
        case GLKLightProgram:
            self.lightProgram = program;
            glLinkProgram(self.lightProgram);
            break;
        default:
            break;
    }
}

- (GLint)loadProgramWithVetexShaderName:(NSString *)vextexName fragShaderName:(NSString *)fragName{
    
    GLuint vertexShader, fragShder;
    GLint program = glCreateProgram();
    
    NSString *verPath = [[NSBundle mainBundle] pathForResource:vextexName ofType:nil];
    NSString *fraPath = [[NSBundle mainBundle] pathForResource:fragName ofType:nil];
    
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER filePath:verPath]) {
        NSLog(@"%s: fail load vertex Shader!", __func__);
        return -1;
    }
    
    if (![self compileShader:&fragShder type:GL_FRAGMENT_SHADER filePath:fraPath]) {
        NSLog(@"%s: fail load fragment Shader!", __func__);
        return -1;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShder);
    glDeleteShader(vertexShader);
    glDeleteShader(fragShder);
    
    return program;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath{
    
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (content == nil) {
        NSLog(@"%s: Fail load the shader!", __FUNCTION__);
    }
    
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar info[logLength];
        glGetShaderInfoLog(*shader, logLength, NULL, info);
        NSLog(@"%s: %s", __func__, info);
        
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

@end
