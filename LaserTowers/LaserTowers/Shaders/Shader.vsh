//
//  Shader.vsh
//  LaserTowers
//
//  Created by Eduard Feicho on 23.03.12.
//  Copyright 2012 Eduard Feicho. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
