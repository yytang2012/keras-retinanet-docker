ARG IMAGE_NAME=nvidia/cuda
FROM ${IMAGE_NAME}:10.1-devel-ubuntu18.04 AS base
LABEL maintainer="Yutao Tang <kissingers800@gmail.com>"

ENV CUDNN_VERSION 7.6.0.64
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda10.1 \
            libcudnn7-dev=$CUDNN_VERSION-1+cuda10.1 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

FROM base AS retinaNet-install

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3-dev python3-pip python3-setuptools libgtk2.0-dev git g++ wget make vim

#for python api
RUN pip3 install numpy \
        wheel \
        opencv-python==3.4.5.20 \
        tensorflow-gpu

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

FROM retinaNet-install AS dependent


# Healthcheck
HEALTHCHECK CMD pidof python3 || exit 1


CMD ["/bin/bash"]

