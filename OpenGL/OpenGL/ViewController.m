//
//  ViewController.m
//  OpenGL
//
//  Created by cy on 16/09/2017.
//  Copyright © 2017 com.jiemu.OpenGL. All rights reserved.
//
#import "ViewController.h"


@interface ViewController ()
@property (nonatomic,strong) GLKBaseEffect *baseEffct;
@property (nonatomic,assign) GLint program;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glkView = (GLKView *)self.view;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glkView.context = context;
    [EAGLContext setCurrentContext:glkView.context];
    
    self.program = [self loadShader];
    glLinkProgram(self.program);
    GLint success;
    glGetProgramiv(self.program, GL_LINK_STATUS, &success);
    
    if (success == GL_FALSE) {
        GLchar info[256];
        glGetProgramInfoLog(self.program, 256, 0, info);
        NSLog(@"%s", info);
        return;
    }
    
    GLfloat vertexArray[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f, 0.5f, 0.0f
    };
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "aPosition");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GL_FLOAT), 0);
    glEnableVertexAttribArray(position);
}

- (GLint)loadShader{
    GLuint verShaper, fraShaper;
    GLint program = glCreateProgram();
    
    NSString *verPath = [[NSBundle mainBundle] pathForResource:@"Shader.vsh" ofType:nil];
    NSString *fraPath = [[NSBundle mainBundle] pathForResource:@"Shader.fsh" ofType:nil];
    [self compileShader:&verShaper type:GL_VERTEX_SHADER file:verPath];
    [self compileShader:&fraShaper type:GL_FRAGMENT_SHADER file:fraPath];
    
    glAttachShader(program, verShaper);
    glAttachShader(program, fraShaper);
    
    glDeleteShader(verShaper);
    glDeleteShader(fraShaper);
    
    return program;
}

- (void)compileShader:(GLuint *)shaper type:(GLenum)type file:(NSString *)file{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shaper = glCreateShader(type);
    glShaderSource(*shaper, 1, &source, nil);
    glCompileShader(*shaper);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(self.program);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
