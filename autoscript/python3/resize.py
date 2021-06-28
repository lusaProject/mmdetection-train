# Author:Tang Peng
import os
import cv2
import numpy as np
import glob

source_path = '/home/lusa/Desktop/draw/draw_1fps/'   # 操作文件路径
source_dest = '/home/lusa/Desktop/resize/'           # 存放文件路径

print(source_path)
dir = source_path
count = 0

for root, dir, files in os.walk(dir):
    for file in files:
        image = source_path + str(file)
        print(image)

        # 读取图片
        src = cv2.imread(image)

        # 图像缩放
        result = cv2.resize(src, (960, 540))

        cv2.imshow("result", result)

        resizeImage =  source_dest + str(file)

        # 写入图像
        cv2.imwrite(str(resizeImage), result)

# 等待显示
cv2.waitKey(0)
cv2.destroyAllWindows()
