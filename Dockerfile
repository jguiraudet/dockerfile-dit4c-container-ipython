# DOCKER-VERSION 1.0
FROM jguiraudet/dit4c-container-base:8.0-cudnn5-devel
MAINTAINER jguiraudet@gmail.com

# Install
# - build dependencies for Python PIP
# - ccache to make building faster
# - virtualenv to setup python environment
# - matplotlib dependencies
# - scipy dependencies
# - pytables dependencies
# - netcdf4 dependencies
# - nltk dependencies
# - Xvfb for Python modules requiring X11
# - GhostScript & ImageMagick for image manipulation
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  gcc  python3 \
  ccache \
  libblas-dev liblapack-dev \
  libpng-dev libfreetype6-dev \
  libhdf5-dev \
   \
  libyaml-dev python-tk \
  Xvfb \
  ghostscript ImageMagick build-essential python3-dev

RUN mkdir /opt/ipython && mkdir /opt/python && \
    chown researcher:researcher /opt/ipython && \
    chown researcher:researcher /opt/python

USER researcher

# Install system-indepedent python environment
RUN python3 -m venv --without-pip /opt/python && \
  cd /tmp && \
  curl -L -s https://bootstrap.pypa.io/get-pip.py | /opt/python/bin/python

# Install from PIP, using ccache to speed build
# - Updates for setuptools, pip & wheels
# - Notebook dependencies
# - IPython (with notebook)
# - Readline for usability
# - Missing IPython dependencies
# - Useful IPython libraries
# - SciPy & netCDF4 (which expect numpy to be installed first)
RUN . /opt/python/bin/activate && \
  PATH=/usr/lib64/ccache:$PATH && \
  pip install --upgrade pip wheel && \
  pip install \
    tornado pyzmq jinja2 \
    ipython jupyter \
    jsonschema \
    ipythonblocks numpy pandas matplotlib gitpython && \
  pip install scipy netCDF4 && \
  pip install numexpr cython && \
  pip install tables && \
  pip install seaborn && \
  ccache --show-stats && \
  ccache --clear && \
  rm -rf /home/researcher/.cache

# Install NLTK, textblob & pyStatParser
RUN /opt/python/bin/pip install nltk textblob pyyaml && \
  /opt/python/bin/pip install git+https://github.com/emilmont/pyStatParser.git@master#egg=pyStatParser && \
  rm -rf /home/researcher/.cache

# Create IPython profile
RUN IPYTHONDIR=/opt/ipython /opt/python/bin/ipython profile create default && \
  rm -rf /home/researcher/.ipython

USER root

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var

RUN chown -R researcher:researcher /opt/ipython

# Check nginx config is OK
RUN nginx -t
