# An example of image writing in Python
# Create a new image, and save it as a .jpg file
# M.S. Branicky, 2020-10-25

from PIL import Image

# 0xNUM is how to put a HEXadecimal (base 16: digits 0-F) constant into Python
# See http://cloford.com/resources/colours/500col.htm for HEX color codes
BLACK   = (  0,   0,   0)    # 0x000000
WHITE   = (255, 255, 255)    # 0xFFFFFF
BLUE    = (  0,   0, 255)    # 0x0000FF
LIME    = (  0, 255,   0)    # 0x00FF00
RED     = (255,   0,   0)    # 0xFF0000
CYAN    = (  0, 255, 255)    # 0x00FFFF = LIME + BLUE
MAGENTA = (255,   0, 255)    # 0xFF00FF = RED  + BLUE
YELLOW  = (255, 255,   0)    # 0xFFFF00 = RED  + LIME 

# create a new, "blank" 500 by 300 image
xsize = 500
ysize = 300
myimage = Image.new("RGB", (xsize, ysize))

# See http://cloford.com/resources/colours/500col.htm for RGB color codes
darkgoldenrod = (184, 134, 11)
thistle = (216, 191, 216)
wulfenite = (233, 116, 20)
outlookblue = (38, 147, 204)

colors = [BLACK, WHITE, BLUE, LIME, RED, CYAN, MAGENTA, YELLOW, outlookblue, wulfenite]

band_width = xsize//len(colors)
for i in range(len(colors)):
    color = colors[i]
    xoffset = i*band_width
    for x in range(xoffset, xoffset+band_width):
        for y in range(ysize):
            myimage.putpixel((x, y), color)

# store the image in a file
myimage.save('myimage.jpg')
