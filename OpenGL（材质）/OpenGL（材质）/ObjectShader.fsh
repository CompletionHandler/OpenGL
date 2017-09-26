//
//  ObjectShader.fsh
//  OpenGL（材质）
//
//  Created by cy on 26/09/2017.
//  Copyright © 2017 com.jiemu.OpenGLTexture. All rights reserved.
//

struct Material {
    lowp vec3 ambient;//环境光
    lowp vec3 diffuse;//漫反射
    lowp vec3 specular;//亮度
    lowp float shininess;//发光值
};
uniform Material material;

struct Light {
    lowp vec3 ambient;//环境光
    lowp vec3 diffuse;//漫反射
    lowp vec3 specular;//亮度
    lowp vec3 position;//光源位置
};
uniform Light light;

uniform mediump vec3 viewPos;

varying lowp vec3 fragPos;
varying lowp vec3 normal;


void main(){
    
    lowp vec3 ambient = light.ambient * material.ambient;
    
    lowp vec3 lightDir = normalize(light.position - fragPos);
    lowp float diff = max(dot(normal, lightDir), 0.0);
    lowp vec3 diffuse = light.diffuse * (material.diffuse * diff);
    
    mediump vec3 viewDir = normalize(viewPos - fragPos);
    mediump vec3 refelectDir = reflect(-lightDir, normal);
    mediump float spec = pow(max(dot(refelectDir, viewDir), 0.0), material.shininess);
    lowp vec3 specular = light.specular * (material.specular * spec);
    
    lowp vec3 result = ambient + diffuse + specular;
    
    gl_FragColor = vec4(result, 1.0);
}
