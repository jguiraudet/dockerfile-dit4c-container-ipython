# DOCKER-VERSION 1.0
FROM dit4c/dit4c-container-base:latest
MAINTAINER t.dettrick@uq.edu.au

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
RUN rpm --rebuilddb && yum install -y \
  gcc gcc-c++ python34-devel \
  ccache \
  blas-devel lapack-devel \
  libpng-devel freetype-devel \
  hdf5-devel \
  netcdf-devel \
  libyaml-devel tkinter \
  xorg-x11-server-Xvfb \
  ghostscript ImageMagick

RUN  mkdir /opt/ipython && mkdir /opt/python && \
    chown researcher:researcher /opt/ipython && \
    chown researcher:researcher /opt/python

USER root
USER researcher

# Install system-indepedent python environment
RUN pyvenv-3.4 --without-pip /opt/python && \
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
RUN source /opt/python/bin/activate && \
  PATH=/usr/lib64/ccache:$PATH && \
  pip install --upgrade pip wheel && \
  pip install \
    tornado pyzmq jinja2 \
    ipython jupyter \
    jsonschema \
    ipythonblocks numpy pandas matplotlib gitpython && \
  pip install scipy netCDF4 && \
  pip install numexpr cython && \
  pip install git+git://github.com/pytables/pytables@develop && \
  ccache --show-stats && \
  ccache --clear && \
  rm -rf /home/researcher/.cache

# Install NLTK, textblob & pyStatParser
RUN /opt/python/bin/pip install nltk textblob pyyaml && \
  /opt/python/bin/pip install git+https://github.com/emilmont/pyStatParser.git@master#egg=pyStatParser && \
  rm -rf /home/researcher/.cache

# Create IPython profile, then
# install MathJAX locally because CDN is HTTP-only
RUN IPYTHONDIR=/opt/ipython /opt/python/bin/ipython profile create default && \
  /opt/python/bin/python -c "from IPython.external.mathjax import install_mathjax; install_mathjax()" && \
  rm -rf /home/researcher/.ipython

USER root

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var

RUN chown -R researcher:researcher /opt/ipython

# Check nginx config is OK
RUN nginx -t
