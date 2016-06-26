#!/usr/bin/env python

# _*_ coding: utf-8 _*_

import numpy as np
import math
import sys
import random as rd
import spidev
import time

origin = [0,0,0]

def bg_rgbs(loc_of_leds,rgb):
    out = []
    for loc_of_led in loc_of_leds:
        out.append([rgb[0],rgb[1],rgb[2]])
    return out

def distance_to_brightness(distance,max,para):
    if distance == 0:
        brightness = max
    else:
        brightness = (max / (distance * distance)) /para 
    if brightness > max:
        brightness = max
    return int(brightness)


def brightness_to_rgb(brightness, rgb_ratio, max):
    f = 1.0 
    red = rgb_ratio[0] * brightness ** (1+f) 
    green = rgb_ratio[1] * brightness ** (1+f)
    blue = rgb_ratio[2] * brightness ** (1+f)
    if red > max:
        red = max
    if green > max:
        green = max
    if blue > max:
        blue = max
    return [int(red),int(green),int(blue)] 

loc_of_leds = []

for i in range(10):
    for j in range(5):
        for k in range(5):
            loc_of_leds.append([i,j,k])

vec = np.array([rd.randint(1,10),rd.randint(1,10),rd.randint(1,10)])
vec2 = np.array([rd.randint(-10,-1),rd.randint(-10,-1),rd.randint(-10,-1)])

nvec = vec / np.linalg.norm(vec)
nvec2 = vec2 / np.linalg.norm(vec2)

star = origin
star2 = [9,4,4]


bg_rgbs = bg_rgbs(loc_of_leds,[0,0,15])

CE=0
spi = spidev.SpiDev()
spi.open(0,CE)


while True:
    
    n1 = rd.randint(100,300)
    n2 = rd.randint(10,50)
    
    rgbs = []
    
    for i in range(n1):
        star = star + nvec / 2.0
        if not (-1 < star[0] < 10):
            nvec[0] = -nvec[0]
        if not (-1 < star[1] < 5):
            nvec[1] = -nvec[1]
        if not (-1 < star[2] < 5):
            nvec[2] = -nvec[2]
    
        star2 = star2 + nvec2 / 5.0 
        if not (-1 < star2[0] < 10):
            nvec2[0] = -nvec2[0]
        if not (-1 < star2[1] < 5):
            nvec2[1] = -nvec2[1]
        if not (-1 < star2[2] < 5):
            nvec2[2] = -nvec2[2]
    
        rgbs=[]
        rgbs2=[]
        for loc_of_led in loc_of_leds:
            distance = np.linalg.norm(loc_of_led - star)
            brightness = distance_to_brightness(distance,150,7.0)
            rgbs.append(brightness_to_rgb(brightness,[1,0,0],150)) 
            distance2 = np.linalg.norm(loc_of_led - star2)
            brightness2 = distance_to_brightness(distance2,150,7.0)
    ##        rgbs2.append(brightness_to_rgb(brightness2,[0.33,0.33,0.33],150))
            rgbs2.append(brightness_to_rgb(brightness2,[0.0,1.0,0],150))
    
        rgbs = np.array(rgbs)
        rgbs2 = np.array(rgbs2)
        bg_rgbs = np.array(bg_rgbs)
    #    rgbs = rgbs +  bg_rgbs
        rgbs = rgbs +  rgbs2 + bg_rgbs
    
        rgbs_s1 = rgbs[0:125]
        rgbs_s2 = rgbs[125:]
    
        rgbs_s1 = rgbs_s1.reshape(5,5,5,3)
        rgbs_s2 = rgbs_s2.reshape(5,5,5,3)
    
        outs1 = np.array([[[[0,0,0]]*5]*5]*5)
        for i in range(5):
            for j in range(5):
                for k in range(5):
                    outs1[i][j][k] = rgbs_s1[j][k][i]
    
        outs2 = np.array([[[[0,0,0]]*5]*5]*5)
        for i in range(5):
            for j in range(5):
                for k in range(5):
                    outs2[i][j][k] = rgbs_s2[j][k][i]
    
    #    rgbs_s1 = rgbs_s1.reshape(125,3)
    
    #    rgbs = rgbs.tolist()
        outs1 = outs1.reshape(125,3)
        outs1 = outs1.tolist()
        outs2 = outs2.reshape(125,3)
        outs2 = outs2.tolist()
    
        outs = outs1 + outs2
        for out in outs:
            spi.writebytes(out)
        spi.writebytes([0xff])        
    
        #time.sleep(0.1)
    
    for i in range(n2):
        rgbs = []
        for x in range(250):
            red = rd.randint(0,30)
            green = rd.randint(0,30)
            blue = rd.randint(0,30)
            rgbs.append([red,green,blue])
        for rgb in rgbs:
            spi.writebytes(rgb)
        spi.writebytes([0xff])
        time.sleep(0.2)
