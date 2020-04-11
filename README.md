# openpose-docker
A docker build file for Retinanet: 
https://github.com/fizyr/keras-retinanet.git


### Requirements
- Nvidia Docker runtime: https://github.com/NVIDIA/nvidia-docker#quickstart
- CUDA 10.1 or higher on your host, check with `nvidia-smi`

### Example
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

- Train Coco dataset in container
    ```shell script
      cd /retinanet/keras_retinanet/bin && \
      python3 train.py --snapshot-path /snapshots \
        coco /datasets/coco/
    ```

- Save and Load docker image
    ```shell script
      docker save retinanet > retinanet.tar
      docker load < retinanet.tar
    ```

The retinaNet repo is in `/retinanet`

# issue
If meet the following error

`xhost local:root`