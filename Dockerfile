# Docker file for gitlab CI test image

FROM centos:6.8

MAINTAINER Frederik Zahle <frza@dtu.dk>

ENV SHELL /bin/bash
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV CONDA_ENV_PATH /opt/miniconda
ENV PATH $CONDA_ENV_PATH/bin:$PATH

RUN yum -y update; yum clean all \
 && yum install -y -q \
    tar \
    wget \
    bzip2 \
    git-all

RUN yum -y install centos-release-scl
RUN yum -y install devtoolset-7
#RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/devtoolset-3/epel-6-x86_64/download/rhscl-devtoolset-3-epel-6-x86_64.noarch.rpm && \
#    yum clean all \
#&& yum install -y devtoolset-3-gcc devtoolset-3-binutils devtoolset-3-gcc-c++ devtoolset-3-gcc-gfortran && yum clean all \
RUN /usr/bin/scl enable devtoolset-7 bash

# add devtoolset to PATH and LD_LIBRARY_PATH
ENV PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH /opt/rh/devtoolset-7/root/usr/lib64

RUN gfortran --version

# openmpi
RUN wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz \ 
  && tar -xzf openmpi-3.1.2.tar.gz \
  && cd openmpi-3.1.2 \
  && ./configure --prefix=/usr/local \
  && make all install


# Install miniconda to /miniconda
RUN wget --quiet \
    https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
    bash Miniconda-latest-Linux-x86_64.sh -b -p $CONDA_ENV_PATH && \
    rm Miniconda-latest-Linux-x86_64.sh && \
    chmod -R a+rx $CONDA_ENV_PATH
RUN conda update --quiet --yes conda \
  && conda create -y -n py37 python=3.7 \
  && conda create -y -n py35 python=3.5 \
  && conda create -y -n py27 python=2.7 \
  && /bin/bash -c "source activate py27 \
  && conda install pip numpy scipy nose hdf5" \
  && /bin/bash -c "source activate py35 \
  && conda install pip numpy scipy nose hdf5" \
  && /bin/bash -c "source activate py37 \
  && conda install pip numpy scipy nose hdf5"

RUN /bin/bash -c "source activate py27 \
  && pip install --upgrade pip \
  && pip install Cython \
  && pip install coverage \
  && pip install mpi4py" \
  && /bin/bash -c "source activate py37 \
  && pip install --upgrade pip \
  && pip install Cython \
  && pip install coverage \
  && pip install mpi4py"

