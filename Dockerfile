# DOCKER-VERSION 1.0
FROM dit4c/dit4c-container-base
MAINTAINER t.dettrick@uq.edu.au

# Install
# - build dependencies for Python PIP
# - virtualenv to setup python environment
# - matplotlib dependencies
# - scipy dependencies
# - pytables dependencies
# - netcdf4 dependencies
# - nltk dependencies
RUN yum install -y \
  gcc python-devel \
  python-virtualenv \
  blas-devel lapack-devel \
  libpng-devel freetype-devel \
  hdf5-devel \
  netcdf-devel \
  libyaml-devel

# Install system-indepedent python environment
RUN virtualenv /opt/python

# Install from PIP
# - Notebook dependencies
# - IPython (with notebook)
# - Readline for usability
# - Useful IPython libraries
# - Missing IPython dependency
RUN /opt/python/bin/pip install --upgrade setuptools==9.1 && \
  /opt/python/bin/pip install \
    tornado pyzmq jinja2 \
    ipython \
    pyreadline \
    ipythonblocks numpy pandas scipy matplotlib netCDF4 gitpython \
    jsonschema

# Install pytables
RUN /opt/python/bin/pip install numexpr cython && \
  /opt/python/bin/pip install git+git://github.com/pytables/pytables@develop

# Install NLTK
RUN yum install -y tkinter && \
  /opt/python/bin/pip install nltk pyyaml

# Create IPython profile, then
# install MathJAX locally because CDN is HTTP-only
RUN mkdir -p /opt/ipython && \
  IPYTHONDIR=/opt/ipython /opt/python/bin/ipython profile create default && \
  /opt/python/bin/python -c "from IPython.external.mathjax import install_mathjax; install_mathjax()" && \
  chown -R researcher /opt/python /opt/ipython

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var
# Chowned to root, so reverse that change
RUN chown -R researcher /opt/{,i}python /var/log/{easydav,supervisor}

# Check nginx config is OK
RUN nginx -t
