#! /usr/bin/env python3

import numpy as np 
from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_output_dir(directory):

    if not os.path.exists(directory):
        os.makedirs(directory)

def generate_gradient_image(width,height):
    img = np.zeros((height,width,3), dtype=np.uint8)

    for y in range(height):
        for x in range(width):
            img[y,x] = [int(255*x/width),int(255*y/height),128]
    return Image.fromarray(img)

def generate_circles(width,height,num_circles=10)
    img = Image.new('RGB',(width,height),color=(50,50,50))
    draw = ImageDraw.Draw(img)

    np.random.seed(42)
    for i in range(num_circles):
        x = np.random.randint(0,width)
        y = np.random.randint(0,height)
        r = np.random.randint(10,min(width,height)//4)
        color = tuple(np.random.randint(0,256,3).tolist())
        draw.ellipse([x-r,y-r,x+r,y+r],fill=color,outline=color)

    return img

def generate_noise_image(width,height,noise_level=50):
    base = np.full((height,width,3),128,dtype=np.uint8)
    noise = np.random.randint(-noise_level,noise_level,(height,width,3))
    img = np.clip(base+nopise,0,255).astype(np.uint8)
    return Image.fromarray(img)

def generate_stripes(width,height,stripe_width=10):
    img = np.zeros((height,width,3),dtype=np.uint8)
    for x in range(0,width,stripe_width*2):
        img[:,x:x+stripe_width] = [np.random.randint(100,255) for _ in range(3)]
    
    return Image.fromarray(img)

def generate_radial_pattern(width,height):

    img = np.zeros((height,width,3),dtype=np.uint8)
    center_x, center_y = width//2, height//2
    max_dist = np.sqrt(center_x**2 + center_y**2)

    for y in range(height):
        for x in range(width):
            dist = np.sqrt((x-center_x)**2 + (y-center_y)**2)
            intensity = int(255*(dist/max_dist))
            img[y,x] = [intensity, 255-intensity,128]
    
    return Image.fromarray(img)


def main():
    num_images = 100
    image_width = 256
    image_height = 256
    output_dir = "input"

    if len(sys.argv) > 1:
        num_images = int(sys.argv[1])
    
    if len(sys.argv) > 2:
        image_width = int(sys.argv[2])
    
    if len(sys.argv) > 3:
        image_height = int(sys.argv[3])
    
    create_output_dir(output_dir)

    generators = [
        ("Gradient",lambda: generate_gradient_image(image_width,image_height)),
        ("Checkerboard", lambda: generate_stripes(image_width,image_height)),
        ("Circles", lambda: generate_circles(image_width,image_height)),
        ("Noise", lambda: generate_noise_image(image_width,image_height)),
         ("Radial", lambda: generate_radial_pattern(image_width,image_height)), 
    ]

    for i in range(num_images):

        pattern_name, generator = generators[i%len(generators)]

        if i % len(generators) < len(generators) -1 :
            img = generator()
        
        else: 
            img = generator()
        
        filename = os.path.join(output_dir,f"input_{i:03d}.png")
        img.save(filename)

if __name__ == "__main__":

    try: 
        import PIL
        main()
    except ImportError:
        print("Pillow is not installed")
        sys.exit(1)