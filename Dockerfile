# DOCKER-VERSION 1.0
FROM dit4c/dit4c-container-base:latest
MAINTAINER t.dettrick@uq.edu.au

# Install
# - build dependencies for Python PIP
# - virtualenv to setup python environment
# - matplotlib dependencies
# - scipy dependencies
# - pytables dependencies
# - netcdf4 dependencies
# - nltk dependencies
# - Xvfb for Python modules requiring X11
# - GhostScript & ImageMagick for image manipulation
RUN rpm --rebuilddb && fsudo yum install -y \
  gcc python-devel \
  python-virtualenv \
  blas-devel lapack-devel \
  libpng-devel freetype-devel \
  hdf5-devel \
  netcdf-devel \
  libyaml-devel tkinter \
  xorg-x11-server-Xvfb \
  ghostscript ImageMagick

# Install system-indepedent python environment
RUN virtualenv /opt/python && \
  mkdir -p /opt/ipython

# Install from PIP
# - Updates for setuptools, pip & wheels
# - Notebook dependencies
# - IPython (with notebook)
# - Readline for usability
# - Missing IPython dependencies
# - Useful IPython libraries
# - SciPy & netCDF4 (which expect numpy to be installed first)
RUN source /opt/python/bin/activate && \
  pip install --upgrade setuptools pip wheel && \
  pip install \
    tornado pyzmq jinja2 \
    ipython \
    pyreadline \
    jsonschema functools32 \
    ipythonblocks numpy pandas matplotlib gitpython && \
  pip install scipy netCDF4 && \
  rm -rf /home/researcher/.cache

# Install pytables
RUN /opt/python/bin/pip install numexpr cython && \
  /opt/python/bin/pip install git+git://github.com/pytables/pytables@develop && \
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

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var

# Because COPY doesn't respoect USER...
USER root
RUN chown -R researcher:researcher /etc /opt /var
USER researcher

# Check nginx config is OK
RUN nginx -t
