#!/bin/bash

_user="$(id -u -n)"

if [ "$_user" == "researcher" ]; then
  export PATH=/opt/python/bin:$PATH
  export IPYTHONDIR=/opt/ipython
  export DISPLAY=:99
  export NLTK_DATA=/mnt/shared/nltk_data
fi
