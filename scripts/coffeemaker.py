#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'PyYoshi'

import time
import os
import warnings
from subprocess import Popen, STDOUT, PIPE

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer

############################################################
########################### 設定 ###########################
############################################################

# coffeeバイナリのパス
CoffeeBinPath = r'E:\dev\node\node_modules\npm\coffee.cmd'
# coffeeファイルの拡張子
CoffeeFileExt= '.coffee'
# *.coffeeファイルを検索するディレクトリパス
SearchCoffeeFileDirPath = r'E:\MySourcecode\git\Tweet_Now_Watching\src\js'
# ファイルが編集されてからビルドされるまでの遅延時間
DelaySecond = 10

############################################################
####################### メインコード #######################
############################################################


subproc_args = {
    'stdin': PIPE,
    'stdout': PIPE,
    'stderr': PIPE,
    'cwd': None,
    'close_fds': False, # Windowsでは使用できないのでFalse
}

def getext(filename):
    """ Get filename ext.
    Args:
        filename str, file path
    Returns:
        str, file ext
    """
    return os.path.splitext(filename)[-1].lower()

class ChangeBuildingHandler(FileSystemEventHandler):
    """"""

    def on_created(self, event):
        pass

    def on_modified(self, event):
        if event.is_directory:
            return
        if getext(event.src_path) == CoffeeFileExt:
            try:
                print('Building %s'% event.src_path)
                exec_args = [CoffeeBinPath, '-b' ,'-c', event.src_path]
                p = Popen(exec_args,**subproc_args)
                err_msg = p.stderr.read()
                del p
                if not err_msg.startswith('path.exists'):
                    print err_msg
            except OSError as e:
                warnings.warn(e.message)


    def on_deleted(self, event):
        pass

    def on_any_event(self, event):
        pass

    def on_moved(self, event):
        pass


if __name__ in '__main__':
    while True:
        handler = ChangeBuildingHandler()
        obsrv = Observer()
        obsrv.schedule(handler, SearchCoffeeFileDirPath, recursive=True)
        obsrv.start()
        try:
            while True:
                time.sleep(DelaySecond)
        except KeyboardInterrupt:
            obsrv.stop()
        obsrv.join()

