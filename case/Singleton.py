# -*- coding: utf-8 -*- 
"""
@Author: litaoa@uniontech.com

@Create time: 2021-06-25 14:50
"""
import threading
import weakref


class Singleton(type):
    _instance_lock = threading.Lock()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        Singleton.__instance = None
        self._cache = weakref.WeakValueDictionary()

    def __call__(self, *args, **kwargs):
        kargs = ''.join('%s' % key for key in args) if args else ''
        kkwargs = ''.join(list('%s' % key for key in kwargs.keys())) if kwargs else ''
        if kargs + kkwargs not in self._cache:
            with Singleton._instance_lock:
                Singleton.__instance = super().__call__(*args, **kwargs)
                self._cache[kargs + kkwargs] = Singleton.__instance
        else:
            Singleton.__instance = self._cache[kargs + kkwargs]
        return Singleton.__instance
