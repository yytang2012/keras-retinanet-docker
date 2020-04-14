# openpose-docker
A docker build file for Retinanet: 
https://github.com/fizyr/keras-retinanet.git


### Requirements
- Nvidia Docker runtime: https://github.com/NVIDIA/nvidia-docker#quickstart
- CUDA 10.1 or higher on your host, check with `nvidia-smi`

### Host machine
- Build image 
    ```shell script
    docker build . -t retinanet:latest
    ```

- Run container
    ```shell script
    docker run -it --rm --runtime=nvidia retinanet:latest /bin/bash
    ```
    or
    ```shell script
      export WORK_DIR=~/Documents/retinanet/ && \
      export DATASET_DIR=~/Documents/datasets && \
      mkdir -p $WORK_DIR/dot_keras && \
      mkdir -p $WORK_DIR/snapshots && \
      docker run  -v $WORK_DIR/dot_keras:/root/.keras \
      -v $DATASET_DIR:/datasets \
      -v $WORK_DIR/snapshots:/snapshots/ \
      -v /etc/localtime:/etc/localtime \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1  \
      -it --rm --runtime=nvidia \
      --name retinanet retinanet:latest  /bin/bash
    ```

- Converting a training model to inference model
    - Running directly from the repository:
    
        `keras_retinanet/bin/convert_model.py /path/to/training/model.h5 /path/to/save/inference/model.h5`

    - Using the installed script:
    
        `retinanet-convert-model /path/to/training/model.h5 /path/to/save/inference/model.h5`

- Save and Load docker image
    ```shell script
      docker save retinanet > retinanet.tar
      docker load < retinanet.tar
    ```

### In container
- Train Coco dataset in container
    ```shell script
      cd /retinanet/keras_retinanet/bin && \
      python3 train.py --snapshot-path /snapshots \
        coco /datasets/coco/
    ```
- Resume training from a snapshot
    ```shell script
      cd /retinanet/keras_retinanet/bin && \
      python3 train.py --snapshot /snapshots/resnet50_coco_50.h5 \
        --initial-epoch 50 --epochs 100 \
        coco /datasets/coco/
    ```

The retinaNet repo is in `/retinanet`

### issue
If meet the following error

`xhost local:root`