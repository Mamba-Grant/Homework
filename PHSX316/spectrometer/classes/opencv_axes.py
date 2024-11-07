import cv2
import numpy as np
from utils.helpers import projectArray2Line

class Axes:
    def __init__(self, cvImg, countx=16, county=16):
        # if settings need to be set do that here.
        self.img = cvImg
        self.countx = countx
        self.county = county

    def getAxis(self, size):
        height, width, _ = self.img.shape
        line_start_x_array = np.linspace(0, width, num=size)
        # line_start_y_array = np.linspace(0, height//2, num=count) # weird division done to put grid above sample line
        axisValues = projectArray2Line( line_start_x_array, 338-40, 588, 194-40, 402 )
        return axisValues

    def drawGrid(self, color=(228, 226, 227), thickness=1, alpha=0.4):
        height, width, _ = self.img.shape
        line_start_x_array = np.linspace(20, width-20, num=self.countx)
        line_start_y_array = np.linspace(20, height//2 - 20, num=self.county) # weird division done to put grid above sample line
        overlay = self.img.copy()

        cv2.rectangle(overlay, (0,0), (width, height // 2), color, thickness)

        for _, (x, y) in enumerate(zip(line_start_x_array, line_start_y_array)):
            # print(x)
            cv2.line(overlay, (int(x), 0), (int(x), height//2), color, thickness)  # vertical grid lines
            cv2.line(overlay, (0, int(y)), (width, int(y)), color, thickness)  # horizontal grid lines

        self.img = cv2.addWeighted(overlay, alpha, self.img, 1-alpha, 0)

    # I should generalize this sometime, but for now its application-specific
    def drawAxes(self, size=0.2, font_color=(59,56,57), font_thickness=1):
        height, width, _ = self.img.shape
        self.drawGrid()
        self.img = cv2.copyMakeBorder(self.img, 40, 40, 40, 40, cv2.BORDER_CONSTANT, value=(228, 226, 227))

        line_start_x_array = np.linspace(20, width-20, num=self.countx)
        line_start_y_array = np.linspace(20, height//2 - 20, num=self.county) # weird division done to put grid above sample line
        # print(line_start_x_array)

        # wavelength (nm), peak 397 @ pixel 10, 410 @ pixel 20
        wavelength_labels = projectArray2Line( line_start_x_array, 338-40, 588, 194-40, 402 )
        intensity_labels = [round(2*val/height, 2) for val in line_start_y_array]
        intensity_labels = np.flip(intensity_labels)

        for i, (x, y) in enumerate(zip(line_start_x_array, line_start_y_array)):
           cv2.putText( self.img, str(round(wavelength_labels[i],4)), (int(x)+40, 35), cv2.FONT_HERSHEY_SIMPLEX, size, font_color, font_thickness, cv2.LINE_AA)  # x-axis labels
           cv2.putText( self.img, str(round(intensity_labels[i],4)), (2, int(y)+40), cv2.FONT_HERSHEY_SIMPLEX, size, font_color, font_thickness, cv2.LINE_AA)  # y-axis labels

    def show(self, name="UnnamedSpectrometer"):
        cv2.imshow(name, self.img)
