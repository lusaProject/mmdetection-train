# -*- coding: utf-8 -*- 
"""
@Author: litaoa@uniontech.com

@Create time: 2021-06-24 09:11
"""
import _queue
import multiprocessing
from time import sleep

import cv2
import numpy as np

from case.Singleton import Singleton
from mmdet.apis import init_detector, inference_detector, show_result_pyplot


class ImageRecognition(metaclass=Singleton):

    def __init__(self, que):
        config_file = '../xianjin/faster_rcnn_r101_fpn_2x_coco.py'
        checkpoint_file = '../xianjin/epoch_48_all.pth'
        self.model = init_detector(config_file, checkpoint_file, device='cpu')
        self.class_names = self.model.CLASSES
        self.q = que

    @staticmethod
    def video(que):
        cap = cv2.VideoCapture(0)  # 视频进行读取操作以及调用摄像头
        cap.set(3, 1920)  # 设置摄像头分辨率宽度
        cap.set(4, 1080)  # 设置摄像头分辨率高度
        while True:
            ret, frame = cap.read()
            if ret:
                try:
                    que.get(block=False)
                except _queue.Empty:
                    pass
                que.put(frame, block=False)

    def image_recognition(self, element):
        """图像识别"""
        for i in range(0, 20):  # 拉去5次图像识别
            frame = self.q.get(block=True, timeout=1)  # 获取摄像头图像
            result = inference_detector(self.model, frame)  # 图像识别结果
            show_result_pyplot(self.model, frame, result, 0.5)  # 展示识别效果
            # 格式化结果
            bboxes = np.vstack(result)
            labels = [
                np.full(bbox.shape[0], i, dtype=np.int32)
                for i, bbox in enumerate(result)
            ]
            labels = np.concatenate(labels)
            scores = bboxes[:, -1]
            inds = scores > 0.5  # 相似度大于0.5的坐标
            bboxes = bboxes[inds, :]
            labels = labels[inds]
            ele_index = 0
            # 元素所在model_class 索引
            for index, ele in enumerate(self.class_names):
                if ele == element:
                    ele_index = index
                    break
            # 遍历结果
            for _id, label in enumerate(labels):
                if label == ele_index:
                    return bboxes[_id]

    def find_element(self, element):
        """查找元素坐标"""
        location = self.image_recognition(element)  # 图像识别获取元素左上,右下坐标
        left_top = (location[0], location[1])  # 左上坐标
        right_bottom = (location[2], location[3])  # 右下坐标
        return (left_top[0] + right_bottom[0]) / 2, (left_top[1] + right_bottom[1]) / 2


if __name__ == "__main__":
    q = multiprocessing.Queue(maxsize=1)
    image = ImageRecognition(q)
    writer = multiprocessing.Process(target=ImageRecognition.video, args=(q,))
    writer.daemon = True
    writer.start()
    sleep(10)
    # writer.join()
    image.find_element("movie")
    # usb_mk.move_to(*image.find_element("open"))
    # usb_mk.click()
    # usb_mk.move_to(*image.find_element("close"))
    # usb_mk.click()
