# -*- coding: utf-8 -*-
"""
@Author: litaoa@uniontech.com

@Create time: 2021-06-02 10:04
"""
import math
from functools import wraps
from time import sleep

import pypinyin
import serial
import serial.tools.list_ports

GENERAL = {
    "a": "04",
    "b": "05",
    "c": "06",
    "d": "07",
    "e": "08",
    "f": "09",
    "g": "0A",
    "h": "0B",
    "i": "0C",
    "j": "0D",
    "k": "0E",
    "l": "0F",
    "m": "10",
    "n": "11",
    "o": "12",
    "p": "13",
    "q": "14",
    "r": "15",
    "s": "16",
    "t": "17",
    "u": "18",
    "v": "19",
    "w": "1A",
    "x": "1B",
    "y": "1C",
    "z": "1D",
    "1": "1E",
    "2": "1F",
    "3": "20",
    "4": "21",
    "5": "22",
    "6": "23",
    "7": "24",
    "8": "25",
    "9": "26",
    "0": "27",
    "esc": "29",
    "backspace": "2A",
    "tab": "2B",
    "space": "2C",
    "-": "2D",
    "=": "2E",
    "[": "2F",
    "]": "30",
    "\\": "31",
    ";": "33",
    "'": "34",
    "`": "35",
    ",": "36",
    ".": "37",
    "/": "38",
    "caps Lock": "39",
    "f1": "3A",
    "f2": "3B",
    "f3": "3C",
    "f4": "3D",
    "f5": "3E",
    "f6": "3F",
    "f7": "40",
    "f8": "41",
    "f9": "42",
    "f10": "43",
    "f11": "44",
    "f12": "45",
    "print screen": "46",
    "scroll lock": "47",
    "break": "48",
    "pause": "48",
    "insert": "49",
    "home": "4A",
    "page up": "4B",
    "delete": "4C",
    "end": "4D",
    "page down": "4E",
    "right": "4F",
    "left": "50",
    "down": "51",
    "up": "52",
    "enter": "58",
    "ctrl": "E0",
    "shift": "E1",
    "alt": "E2",
    "win": "E3",
}

SHIFT_KEY = {
    "A": "04",
    "B": "05",
    "C": "06",
    "D": "07",
    "E": "08",
    "F": "09",
    "G": "0A",
    "H": "0B",
    "I": "0C",
    "J": "0D",
    "K": "0E",
    "L": "0F",
    "M": "10",
    "N": "11",
    "Oo": "12",
    "P": "13",
    "Q": "14",
    "R": "15",
    "S": "16",
    "T": "17",
    "U": "18",
    "V": "19",
    "W": "1A",
    "X": "1B",
    "Y": "1C",
    "Z": "1D",
    "!": "1E",
    "@": "1F",
    "#": "20",
    "$": "21",
    "%": "22",
    "^": "23",
    "&": "24",
    "*": "25",
    "(": "26",
    ")": "27",
    "_": "2D",
    "+": "2E",
    "{": "2F",
    "}": "30",
    "|": "31",
    ":": "33",
    '"': "34",
    "~": "35",
    "<": "36",
    ">": "37",
    "?": "38",
}


# 鼠标操作装饰器
def mouse(mouseup=True):
    def option(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            func(*args, **kwargs)
            if mouseup:
                usb_mk._write(usb_mk._mouse_sum("00 00 00 00"))

        return wrapper

    return option


# 键盘操作装饰器
def keyboard(key_up=True):
    def option(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            func(*args, **kwargs)
            if key_up:
                usb_mk._write(usb_mk._keyboard_sum())

        return wrapper

    return option


class UsbMk:
    """usb模拟键盘鼠标通信"""

    HEIGHT = 1080
    WIDTH = 1920
    HEAD = "57 AB"
    ADDR = "00"

    def __init__(self, port, baudrate):
        self.ser = serial.Serial()
        self.ser.port = port
        self.ser.baudrate = baudrate
        self.ser.parity = "N"
        self.ser.bytesize = 8
        self.ser.stopbits = 1
        self.ser.timeout = 0.2
        self.ser.open()

    @classmethod
    def calculate_sum(cls, code: str):
        """
        计算code最后一位
        公式：计算方式为： SUM = HEAD+ADDR+CMD+LEN+DATA, 超过一个字节取去掉高位，例如0x212，取 12
        @param code: 指令信息
        @return: 返回完整的 code
        """
        # 格式化处理，code中指令为个位的补全0, 例如1, 补全01
        code = "{} {} {:0>2}".format(
            cls.HEAD,
            cls.ADDR,
            " ".join(map(lambda x: "{:0>2}".format(x), code.split(" "))),
        )
        return "{} {:0>2}".format(
            code, hex(sum(map(lambda x: int(f"0x{x}", 16), code.split(" "))))[-2:]
        )

    def _write(self, code):
        """发送指令"""
        self.ser.write(bytes.fromhex(code))

    @staticmethod
    def pinyin(word):
        """汉字转化为拼音"""
        s = ""
        for key in pypinyin.pinyin(word, style=pypinyin.NORMAL):
            s += "".join(key)
        return s

    def _mouse_sum(self, code: str):
        """鼠标指令计算最后一位累加和"""
        code = self.calculate_sum(f"05 05 01 {code}")
        return code

    def _keyboard_sum(self, general=None):
        """
        键盘指令计算最后一位累加和
        @param general: 仅支持同时操控6个按键
        """
        shift = "00"
        if not general:     # 释放所有按键
            general_code = "00 00 00 00 00 00"
        else:
            general_code = ["00", "00", "00", "00", "00", "00"]
            try:
                if isinstance(general, (str, int, bool)):
                    try:
                        general_code[0] = GENERAL[str(general)]
                    except KeyError:    # 在shift_key中去匹配对应字符
                        general_code[0] = SHIFT_KEY[str(general)]
                        shift = "02"
                else:
                    for index, i in enumerate(general):
                        general_code[index] = GENERAL[str(i.lower())]
            except IndexError as e:
                raise IndexError(f"最多可同时操控6个普通键位！ {e}")
            except KeyError as e:
                raise KeyError(f"UNASSIGNED 未配置的键位code {e}")
            general_code = " ".join(general_code)

        return self.calculate_sum(f"02 08 {shift} 00 {general_code}")

    @keyboard()
    def press_key(self, key: str):
        """按键"""
        self._write(self._keyboard_sum(general=str(key)))

    @keyboard(key_up=False)
    def press_key_down(self, key: str):
        """按键不放"""
        self._write(self._keyboard_sum(general=str(key)))

    @keyboard()
    def hot_key(self, *general):
        """组合按键 注意按键顺序从左到右 最多六个按键"""
        self._write(self._keyboard_sum(general=general))

    @keyboard(key_up=False)
    def hot_key_down(self, *general):
        """组合按键不放"""
        self._write(self._keyboard_sum(general=general))

    @keyboard()
    def key_up(self):
        """释放所有按键"""
        pass

    @mouse()
    def click(self):
        """鼠标左键点击"""
        code = "01 00 00 00"
        self._write(self._mouse_sum(code))

    @mouse(mouseup=False)
    def mouse_down(self):
        """鼠标按下不放"""
        code = "01 00 00 00"
        self._write(self._mouse_sum(code))

    @mouse()
    def mouse_up(self):
        """鼠标按键释放"""
        pass

    @mouse()
    def right_click(self):
        """鼠标右键点击"""
        code = "02 00 00 00"
        self._write(self._mouse_sum(code))

    @mouse()
    def double_click(self, interval=0.05):
        """鼠标左键双击"""
        self.click()
        sleep(interval)
        self.click()

    @mouse(mouseup=False)
    def move_to_init(self, duration=0.0, mousedown=False):
        """
        恢复鼠标至初始位置，默认左上角
        @param duration: 平移时间
        @param mousedown: 是否按下鼠标
        """
        # code = f"{'01' if mousedown else '00'} 80 7f 00"
        code = f"{'01' if mousedown else '00'} 80 80 00"
        num = math.ceil(self.WIDTH / 127)  # 取最大步长
        single_time = duration / num
        single_code = self._mouse_sum(code)
        for _ in range(0, math.ceil(self.WIDTH / 127)):
            self._write(single_code)
            sleep(single_time)

    @staticmethod
    def coord_sequence(list1: tuple, list2: tuple):
        """
        code生成器
        """
        n, b = 0, 0
        code_1, num1 = list1
        code_2, num2 = list2
        max_num, min_num = max(num1, num2), min(num1, num2)
        # 求商作为最小单位
        try:
            answer = max_num // min_num
        except ZeroDivisionError:
            answer = max_num
        # 求余作为剩余分配的code
        try:
            remainder = max_num % min_num
        except ZeroDivisionError:
            remainder = max_num
        a = 0
        while n < num1 + num2:  # 生成最多 num1+ num2个code
            if a == answer + 1 and b < remainder:   # 一组最小单位生成后，并且存在剩余未分配code，分配一次剩余code，并a置为0
                b += 1
                a = 0
                yield code_1 if max_num == num1 else code_2
            else:
                if (a + 1) % (answer + 1) == 0:    # 一组最小单位最后以返回数量较少的code
                    yield code_1 if min_num == num1 else code_2
                else:   # 返回数量较多的code
                    yield code_1 if max_num == num1 else code_2
                a += 1
            n += 1
        return 'done'

    # def move_rel(self, x: int, y: int, duration=0.0, mousedown=False):
    #     """
    #     移动鼠标至相对坐标
    #     @param x: 横向移动， 负数向左，0x80 <= 字节 3 <= 0xFF 正数向右 ：0x01 <= 字节 3 <= 0x7F
    #     @param y: 纵向移动， 负数向下，0x80 <= 字节 3 <= 0xFF 正数向上 0x01 <= 字节 3 <= 0x7F
    #     @param duration: 平移时间
    #     @param mousedown: 是否按下鼠标
    #     @return
    #     """
    #     # 绝对值
    #     x_px = abs(x)
    #     y_px = abs(y)
    #     num = max(x_px, y_px)   # 最大像素作为移动发送指令次数
    #     single_time = duration / num  # 单次移动等待时间
    #     # 步长取1, 公式见方法注释
    #     code_x = 1 if x > 0 else 254
    #     code_y = 1 if y > 0 else 254
    #     # 横纵坐标平移code
    #     direction = (
    #         f"{'01' if mousedown else '00'} {hex(code_x)[2:]} {hex(code_y)[2:]} 00"
    #     )
    #     direction_code = self._mouse_sum(direction)
    #     # 单横/纵坐标平移
    #     single_move = (
    #         f"{'01' if mousedown else '00'} {hex(code_x)[2:]} 00 00"
    #         if x_px > y_px
    #         else f"{'01' if mousedown else '00'} 00 {hex(code_y)[2:]} 00"
    #     )
    #     single_code = self._mouse_sum(single_move)
    #     # 获取生成器
    #     sequence = self.coord_sequence((direction_code, min(x_px, y_px)), (single_code, abs(x_px - y_px)))
    #     # 循环发送指令
    #     for i in sequence:
    #         self._write(i)
    #         sleep(single_time)

    @staticmethod
    def __hcf(x, y):
        """"计算移动步数"""
        if (
                max(x, y) % min(x, y) == 0 and 20 <= max(x, y) / min(x, y) <= 127
        ):  # 能整除,并且商在20~127,则以小数作为步数,商做为步长
            return min(x, y)
        proportion_diff = max(x, y)  # 初始化最大比例
        answer = 1  # 初始化步数
        for i in range(1, min(x, y) + 1):
            x_answer, x_remainder = divmod(x, i)  # 求商和余
            y_answer, y_remainder = divmod(y, i)  # 求商和余
            if any([x_remainder > x_answer, y_remainder > y_answer]):  # 余数大于商,跳过
                continue
            try:
                diff = abs(x_answer / y_answer - x_remainder / y_remainder)  # 比较商的比例与余数的比例
            except ZeroDivisionError:
                diff = x_answer / y_answer
            # 取比例最小,并且步长大于0,小于127
            if all(
                    [
                        proportion_diff > diff,
                        0 < x_answer <= 127,
                        0 < y_answer <= 127,
                    ]
            ):
                proportion_diff, answer = diff, i
        # 返回步数
        return answer

    @classmethod
    def __step_nums(cls, x, y):
        """"计算移动部署"""
        if x <= 127 and y <= 127:  # 横纵坐标小于等于最大步长,则移动一次
            return 1
        elif min(x, y) == 0:
            if max(x, y) <= 127:
                return 1
            else:
                return 8
        elif max(x, y) / min(x, y) < 127:  # 横纵坐标相除小于127,表示相同步数时,存在x,y平移均小于127的情况
            step = cls.__hcf(x, y)
            return step
        else:  # 横纵坐标相除小于127,表示相同步数时,存在x,y平移均大于127的情况,则以最小的数为部署
            return min(x, y)

    @mouse(mouseup=False)
    def move_rel(self, x: int, y: int, duration=0.0, mousedown=False):
        """
        移动鼠标至相对坐标
        @param x: 横向移动， 负数向左，0x80 <= 字节 3 <= 0xFF 正数向右 ：0x01 <= 字节 3 <= 0x7F
        @param y: 纵向移动， 负数向下，0x80 <= 字节 3 <= 0xFF 正数向上 0x01 <= 字节 3 <= 0x7F
        @param duration: 平移时间
        @param mousedown: 是否按下鼠标
        @return
        """
        x, y = int(x/2), int(y/2)
        x_px = abs(x)
        y_px = abs(y)
        step = self.__step_nums(x_px, y_px)
        sleep_amount = duration / step
        x_answer, x_remainder = divmod(x_px, step)  # 求商和余
        y_answer, y_remainder = divmod(y_px, step)  # 求商和余
        # 计算x轴平移code
        code_x = x_answer if x > 0 else (255 - x_answer)
        last_x = x_remainder if x > 0 else (255 - x_remainder)
        # 计算y轴平移code
        code_y = y_answer if x > 0 else (255 - y_answer)
        last_y = y_remainder if x > 0 else (255 - y_remainder)
        # 前面N次平移指令
        direction = (
            f"{'01' if mousedown else '00'} {hex(code_x)[2:]} {hex(code_y)[2:]} 00"
        )
        direction_code = self._mouse_sum(direction)
        # 最后一次平移指令
        last_code = self._mouse_sum(f"{'01' if mousedown else '00'} {hex(last_x)[2:]} {hex(last_y)[2:]} 00")
        for _ in range(0, step):
            sleep(sleep_amount)
            self._write(direction_code)
        self._write(last_code)

    @mouse(mouseup=False)
    def move_to(self, x: int, y: int, duration=0.0, mousedown=False):
        """
        以屏幕左上角为圆心坐标移动鼠标至屏幕绝对坐标
        @param x: x轴像素
        @param y: y轴像素
        @param duration: 平移时间
        @param mousedown: 是否按下鼠标
        @return
        """
        self.move_to_init(mousedown=mousedown)
        self.move_rel(x, y, duration=duration, mousedown=mousedown)

    @mouse()
    def drag_to(self, x, y, duration=0.0):
        """拖动到绝对坐标位置"""
        self.mouse_down()
        self.move_to(x, y, duration=duration, mousedown=True)

    @mouse()
    def drag_rel(self, x, y, duration=0.0):
        """按住拖动到相对坐标位置"""
        self.mouse_down()
        self.move_rel(x, y, duration=duration, mousedown=True)

    @keyboard()
    def input_text(self, text: str):
        """输入字符，仅支持键盘字符及符号，中文自动转换成字母输入"""
        text = self.pinyin(text)
        for i in text:
            if i == " ":
                i = "space"
            self.press_key(i)

    def __del__(self):
        self._write(self._mouse_sum("00 00 00 00"))
        self._write(self._keyboard_sum())
        self.ser.close()

def run():
    import pyautogui
    print(pyautogui.position())

usb_mk = UsbMk("/dev/ttyACM0", 9600)

if __name__ == "__main__":
    usb_mk.move_to(400, 500)
    run()
    # usb_mk.drag_rel(32.88,1033.55)
