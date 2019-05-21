# Docker file for gitlab CI test image

FROM centos:7.2.1511

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
  && conda create -y -n py35 python=3.5 \
  && conda create -y -n py27 python=2.7 \
  && /bin/bash -c "source activate py27 \
  && conda install pip numpy scipy nose hdf5" \
  && /bin/bash -c "source activate py35 \
  && conda install pip numpy scipy nose hdf5" \
  && /bin/bash -c "source activate py37 \
  && conda install pip numpy scipy nose hdf5"

ENV PETSC_CONFIGURE_OPTIONS "--with-shared-libraries --with-fortran-interfaces=1 -with-fortran-bindings --with-fc=mpif90"

RUN update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 999 \
  && update-alternatives --install /usr/bin/gfortran gfortran /usr/local/bin/gfortran 999 \
  && apt-get install libblas-dev liblapack-dev -y \
  && /bin/bash -c "source activate py27 \
  && pip install --upgrade pip \
  && pip install Cython \
  && pip install coverage \
  && pip install mpi4py \
  && pip install -v petsc==3.11 \
  && pip install -v petsc4py==3.11" \
  && /bin/bash -c "source activate py37 \
  && pip install --upgrade pip \
  && pip install Cython \
  && pip install coverage \
  && pip install mpi4py \
  && pip install -v petsc==3.11 \
  && pip install -v petsc4py==3.11"

RUN echo 'ulimit -s unlimited' >> .bashrc
