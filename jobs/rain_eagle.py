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

try:
    raineagle = RainEagle.Eagle(debug=0, addr='10.10.8.70', username=USERNAME, password=PASSWORD)

    print(int(raineagle.get_instantaneous_demand()['InstantaneousDemand']['Demand'], 0))
except:
    pass
