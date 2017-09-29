//
//  ObjectShader.fsh
//  OpenGL（光照贴图）
//
//  Created by cy on 29/09/2017.
//  Copyright © 2017 jiemu. All rights reserved.
//

struct Material {
    sampler2D ambient;//环境光
    sampler2D diffuse;//漫反射
    sampler2D specular;//亮度
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

varying lowp vec2 textCoord;
varying lowp vec3 fragPos;
varying lowp vec3 normal;


void main(){
    lowp vec3 ambient = light.ambient * vec3(texture2D(material.ambient, textCoord));
    
    lowp vec3 lightDir = normalize(light.position - fragPos);
    lowp float diff = max(dot(normal, lightDir), 0.0);
    lowp vec3 diffuse = light.diffuse * vec3(texture2D(material.ambient, textCoord)) * diff;
    
    mediump vec3 viewDir = normalize(viewPos - fragPos);
    mediump vec3 refelectDir = reflect(-lightDir, normal);
    mediump float spec = pow(max(dot(refelectDir, viewDir), 0.0), material.shininess);
    lowp vec3 specular = light.specular * vec3(texture2D(material.specular, textCoord)) * spec;
    
    lowp vec3 result = ambient + diffuse + specular;
    
    gl_FragColor = vec4(result, 1.0);
}
