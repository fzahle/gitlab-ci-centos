# Docker file for gitlab CI test image

FROM centos:7.2.1511

MAINTAINER Paul van der Laan <plaa@dtu.dk>

ENV SHELL /bin/bash
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV CONDA_ENV_PATH /opt/miniconda
ENV PATH $CONDA_ENV_PATH/bin:$PATH

RUN yum -y update; yum clean all \
 && yum install -y -q \
    tar \
    wget \
    bzip2 \
    gcc-gfortran \
    git-all \
    curl \
    gcc gcc-c++ make openssl-devel
RUN wget https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.2.tar.gz \
  && tar -xzf openmpi-1.10.2.tar.gz \
  && cd openmpi-1.10.2 \
  && ./configure --prefix=/usr/local --disable-dlopen \
  && make all install

# Install miniconda to /miniconda
RUN wget --quiet \
    https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
    bash Miniconda-latest-Linux-x86_64.sh -b -p $CONDA_ENV_PATH && \
    rm Miniconda-latest-Linux-x86_64.sh && \
    chmod -R a+rx $CONDA_ENV_PATH
RUN conda update --quiet --yes conda \
  && conda create -y -n py37 python=3.7 \
  && /bin/bash -c "source activate py37 \
  && conda install pip numpy scipy xarray nose"