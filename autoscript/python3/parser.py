#!/usr/bin/env python
# coding=utf-8

import argparse


def main():
    # description描述这个参数解析器是干什么的，当我们在命令行显示帮助信息的时候会看到description描述的信息
    parser = argparse.ArgumentParser(description="demo of argparse")
    # 通过对象的add_argument函数来增加参数。
    # '-n','--name'表示同一个参数,default参数表示在运行命令时若没有提供参数，程序会将此值当做参数值
    parser.add_argument('-n', '--name', default="Li")
    parser.add_argument('-a', '--age', default="21")
    args = parser.parse_args()
    print(args)  # Namespace(age='21', name='Li')
    name = args.name
    age = args.age
    # vars() 函数返回对象object的属性和属性值的字典对象。
    ap = vars(args)
    print(ap)  # {'name': 'Li', 'age': '21'}
    print(ap['name'])  # Li
    print('Hello {} {}'.format(name, age))  # Hello Li 21


if __name__ == '__main__':
    main()
