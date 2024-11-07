import cv2
import numpy as np
from classes.opencv_axes import Axes
from utils.helpers import extractValueChannel

cap = cv2.VideoCapture(2)
cap.set(cv2.CAP_PROP_EXPOSURE, 1) 
cv2.namedWindow("UnnamedSpectrometer")

while True:
    ret, img = cap.read()
    if not ret:
        break

    borderSize = -40
    verticalOffset = -10
    # sampleStart = (borderSize + 80, borderSize + 252)
    # sampleEnd = (borderSize + 393, borderSize + 284)
    sampleStart = (borderSize, borderSize + 139 + verticalOffset)
    sampleEnd = (img.shape[1], borderSize + 220 + verticalOffset)

    #  masking and flattening the sample line into an array of intensity values
    vChannel = extractValueChannel(img)
    mask = np.zeros(img.shape[:2], dtype="uint8")
    cv2.line(mask, sampleStart, sampleEnd, 255, 1)
    masked = cv2.bitwise_and(vChannel, vChannel, mask=mask)
    slice = masked.flatten('F')  # flatten array (column major order)
    slice = slice[slice != 0]  # drop zeroes

    #  rendering flow
    #  post process a sample line onto the image
    img = cv2.bitwise_and(img, img, mask=cv2.bitwise_not(mask))
    cv2.line(img, np.add(sampleStart, (0,1)), np.add(sampleEnd, (0,1)), (28, 169, 147), 1)
    outImage = cv2.add(img, cv2.cvtColor(masked,cv2.COLOR_GRAY2RGB))
    
    #  plot values for intensity
    for x, value in enumerate(slice):
        cv2.circle(outImage, (x, 240 - value), 1, (0, 0, 255), -1)

    # throw the axes on there
    a = Axes(outImage)
    a.drawAxes()
    a.show()
    

    key = cv2.waitKey(1)
    if key == ord('q'):
        break
    elif key == ord('d'):
        for val in slice:
            print(f"{val},",end="")
        print()
        for wavelength in a.getAxis(len(slice)):
            print(f"{wavelength},",end="")

cap.release()
cv2.destroyAllWindows()
