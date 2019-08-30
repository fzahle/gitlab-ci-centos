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
    gcc gcc-c++ make openssl-devel \
    gcc-gfortran \
    git-all

RUN wget https://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.2.tar.gz \
  && tar -xzf openmpi-1.6.2.tar.gz \
  && cd openmpi-1.6.2 \
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

