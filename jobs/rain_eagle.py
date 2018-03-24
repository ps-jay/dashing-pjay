from __future__ import print_function

import os

import RainEagle

USERNAME = os.environ['RE_USERNAME']
PASSWORD = os.environ['RE_PASSWORD']

DEBUG = 0
try:
    DEBUG = os.environ['RE_DEBUG']
except:
    pass

def _undo_twos(str_value, num_digits=None):
    '''Convert a twos complement hex string to a signed int'''
    if num_digits is not None:
        digits = len(str_value) - 2
    else:
        digits = num_digits
    pattern8 = '0x8'
    patternF = '0xF'
    for i in range(1, digits):
        pattern8 += '0'
        patternF += 'F'
    if int(str_value, 16) < int(pattern8, 16):
        n = int(str_value, 16)
    else:
        n = -1 * int(patternF, 16) + int(str_value, 16) - 1
    return n

try:
    raineagle = RainEagle.Eagle(debug=0, addr='10.10.8.41', username=USERNAME, password=PASSWORD)

    reading = raineagle.get_instantaneous_demand()['InstantaneousDemand']['Demand']
    print(_undo_twos(reading, num_digits=8))
except:
    pass
