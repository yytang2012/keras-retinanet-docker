ARG IMAGE_NAME=nvidia/cuda
FROM ${IMAGE_NAME}:10.1-devel-ubuntu18.04 AS base
LABEL maintainer="Yutao Tang <kissingers800@gmail.com>"

ARG CUDNN_VERSION=7.6.4.38
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=${CUDNN_VERSION}-1+cuda10.1 \
            libcudnn7-dev=${CUDNN_VERSION}-1+cuda10.1 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs


## Install TensorRT. Requires that libcudnn7 is installed above.
#ARG LIB_VERSION=6.0.1
#RUN apt-get install -y --no-install-recommends libnvinfer6=${LIB_VERSION}-1+cuda10.1 \
#    libnvinfer-dev=${LIB_VERSION}-1+cuda10.1 \
#    libnvinfer-plugin6=${LIB_VERSION}-1+cuda10.1

FROM base AS ubuntu-cudnn

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3-dev python3-pip python3-setuptools libgtk2.0-dev git g++ wget make vim

# Upgrade pip to latest version is necessary, otherwise the default version cannot install tensorflow 2.1.0
RUN pip3 install --upgrade setuptools pip

#for python api
RUN pip3 install numpy \
        wheel \
        opencv-python==3.4.5.20 \
        tensorflow-gpu

FROM ubuntu-cudnn AS retinaNet-prepare

# Download source code
WORKDIR /retinanet
RUN git clone https://github.com/yytang2012/keras-retinanet.git .

# Install Dependencies
RUN pip3 install -r requirements.txt

# Install retinaNet
RUN python3 setup.py build_ext --inplace

# Download pretrain weights
RUN wget -P /retinanet/snapshots https://github.com/fizyr/keras-retinanet/releases/download/0.5.1/resnet101_oid_v1.0.0.h5
RUN wget -P /retinanet/snapshots https://github.com/fizyr/keras-retinanet/releases/download/0.5.1/resnet152_oid_v1.0.0.h5
RUN wget -P /retinanet/snapshots https://github.com/fizyr/keras-retinanet/releases/download/0.5.1/resnet50_coco_best_v2.1.0.h5
RUN wget -P /retinanet/snapshots https://github.com/fizyr/keras-retinanet/releases/download/0.5.1/resnet50_oid_v1.0.0.h5

FROM retinaNet-prepare AS dependent


# Healthcheck
HEALTHCHECK CMD pidof python3 || exit 1


CMD ["/bin/bash"]

