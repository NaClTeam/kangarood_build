#!/bin/bash

set -e

echo start && apk update && apk add alpine-sdk build-base gcc g++ binutils make cmake python3 python3-dev py3-requests py3-wheel py3-setuptools scons zlib zlib-dev cython py3-elftools nano clang && python3 -m ensurepip && python3 -m pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple pip -U && python3 -m pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && CFLAGS="-flto -fno-fat-lto-objects -Os" python3 -m pip install requests scons tinyaes cython altgraph pyinstaller-hooks-contrib && strip --strip-unneeded /usr/lib/python3.11/site-packages/tinyaes*.so && git clone https://ghproxy.com/https://github.com/pyinstaller/pyinstaller.git -b v5.7.0 --depth=1 --single-branch --no-tags && cd pyinstaller && cd bootloader && CFLAGS="-Os" python3 waf configure build_release install_release -j16 --clang --target-arch=64bit --show-warnings -p --no-lsb && cd .. && PYINSTALLER_COMPILE_BOOTLOADER= python3 -m pip install . && cd && CFLAGS="-flto -fno-fat-lto-objects -Os" python3 -m pip install staticx && rm -rf /usr/lib/python3.11/site-packages/staticx/assets/debug && strip --strip-unneeded /usr/lib/python3.11/site-packages/staticx/assets/release/bootloader && mkdir appnative && cd appnative && wget http://10.0.0.209:14514/appnative.py && cython -D --cplus -3 --lenient appnative.py -o appnative.cpp && gcc -Wno-unused-result -Wsign-compare -DNDEBUG -fwrapv -Os -flto -fno-fat-lto-objects -Wall -fno-strict-aliasing -fomit-frame-pointer -DTHREAD_STACK_SIZE=0x100000 -fPIC -I/usr/include/python3.11 -c appnative.cpp -o appnative.o && g++ -shared -flto -fno-fat-lto-objects -Wl,--as-needed,-Os,--sort-common appnative.o -L/usr/lib -o appnative.so && strip --strip-unneeded appnative.so && cd && mkdir app && cd app && cp -avf ../appnative/appnative.so . && wget http://10.0.0.209:14514/app.py && MY_KEY=$(python3 -c 'from string import ascii_letters,punctuation,digits;from random import shuffle;from secrets import choice;chars=list(ascii_letters+punctuation+digits);shuffle(chars);print("".join([choice(chars) for _ in range(16)]),end="")') && echo my key is $MY_KEY && alias strip=strip\ --strip-unneeded && pyinstaller --clean --onefile --hidden-import base64 --hidden-import binascii --hidden-import datetime --hidden-import json --hidden-import os --hidden-import sys --hidden-import time --hidden-import traceback --hidden-import requests --key ${MY_KEY} --strip app.py && cd && mkdir appstatic && cd appstatic && cp -avf ../app/dist/app . && sed -i 's/\/etc\/resolv.conf/.\/\/\/\/resolv.conf/g' /lib/ld-musl-*.so.1 && staticx --strip app appstatic && echo done
