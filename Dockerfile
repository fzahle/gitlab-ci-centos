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

ENV GCC_VERSION 7.3.0
ENV GMP_VERSION 6.1.2
ENV MPFR_VERSION 3.1.5
ENV MPC_VERSION 1.0.3

RUN yum -y update; yum clean all
RUN yum install -y make libmpc-devel mpfr-devel gmp-devel gcc gcc-c++ m4 bzip2; yum clean all

RUN curl -fSL "https://ftp.gnu.org/gnu/gnu-keyring.gpg" -o /etc/gnu-keyring.gpg \
  && gpg -q --import /etc/gnu-keyring.gpg

RUN mkdir -p /usr/src/gmp \
  && curl -fSL "https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VERSION.tar.xz" -o gmp.tar.xz \
  && curl -fSL "https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VERSION.tar.xz.sig" -o gmp.tar.xz.sig \
  && gpg --batch --verify gmp.tar.xz.sig gmp.tar.xz \
  && tar xf gmp.tar.xz -C /usr/src/gmp --strip-components=1 \
  && cd /usr/src/gmp \
  && rm -f gmp.tar.xz* \
  && ./configure && make -j$(nproc) && make check && make install

RUN mkdir -p /usr/src/mpfr \
  && curl -fSL "https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VERSION.tar.xz" -o mpfr.tar.xz \
  && curl -fSL "https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VERSION.tar.xz.sig" -o mpfr.tar.xz.sig \
  && gpg --batch --verify mpfr.tar.xz.sig mpfr.tar.xz \
  && tar xf mpfr.tar.xz -C /usr/src/mpfr --strip-components=1 \
  && cd /usr/src/mpfr \
  && rm -f mpfr.tar.xz* \
  && ./configure && make -j$(nproc) && make check && make install

RUN mkdir -p /usr/src/mpc \
  && curl -fSL "https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz" -o mpc.tar.xz \
  && curl -fSL "https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz.sig" -o mpc.tar.xz.sig \
  && gpg --batch --verify mpc.tar.xz.sig mpc.tar.xz \
  && tar xf mpc.tar.xz -C /usr/src/mpc --strip-components=1 \
  && cd /usr/src/mpc \
  && rm -f mpc.tar.xz* \
  && ./configure && make -j$(nproc) && make check && make install

RUN mkdir -p /usr/src/gcc \
  && curl -fSL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz" -o gcc.tar.gz \
  && curl -fSL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz.sig" -o gcc.tar.gz.sig \
  && gpg --batch --verify gcc.tar.gz.sig gcc.tar.gz \
  && tar -xzf gcc.tar.gz -C /usr/src/gcc --strip-components=1 \
  && cd /usr/src/gcc \
  && ./configure --disable-bootstrap --disable-multilib -enable-languages=c,c++,fortran \
  && make -j$(nproc) \
  && make install


RUN echo "/usr/local/lib64" >> /etc/ld.so.conf.d/lib64.conf \
  && ldconfig -v



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

RUN echo 'ulimit -s unlimited' >> .bashrc
