# -*- coding: utf-8 -*- 
"""
@Author: litaoa@uniontech.com

@Create time: 2021-06-24 08:58
"""
from time import time, sleep

import pytest

from study.image_recognition import ImageRecognition
from study.usb_mk import usb_mk


@pytest.fixture(scope="session", autouse=False)
def image(request):
    yield ImageRecognition(request.config.option.q)


def test_open_and_close_movie(image):
    """打开关闭影院"""
    usb_mk.move_to(*image.find_element("movie"))
    usb_mk.right_click()
    sleep(1)
    usb_mk.move_to(*image.find_element("open"))
    usb_mk.click()
    sleep(1)
    usb_mk.move_to(*image.find_element("close"))
    usb_mk.click()