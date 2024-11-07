import cv2
import numpy as np

def extractValueChannel(img):
    return cv2.cvtColor(img, cv2.COLOR_BGR2HSV)[:, :, 2]

def projectArray2Line(arr, x1, y1, x2, y2):
    m = (y2 - y1) / (x2 - x1)
    return [m*(x-x1)+y1 for x in arr]

