# -*- coding: utf-8 -*- 
"""
@Author: litaoa@uniontech.com

@Create time: 2021-06-25 14:36
"""
import multiprocessing
from time import sleep

from study.image_recognition import ImageRecognition


def pytest_configure(config):
    q = multiprocessing.Queue(maxsize=1)
    img = multiprocessing.Process(target=ImageRecognition.video, args=(q,))
    img.daemon = True
    img.start()
    ImageRecognition(q)
    config.option.q = q
    sleep(5)