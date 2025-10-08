# argument

# workspace to use
ARG WORKSPACE=/root

# dataset directory relative to WORKSPACE
# you can copy the datasets with docker cp
# we assume dataset is from roboflow and already modified
# do it should has data.yaml file
ARG	DATASETS_DIR=datasets

# training configuration file
# this file is relative to WORKSPACE
# you can copy your own configuration file with docker copy

# for template retraining you can use configs/yolov6n_finetune_cfg.py
# with pt file is models/model_v0.pt, you can just overwrite
# the model_v0.pt file with your own and reuse the training configuration
#ARG TRAINING_CONFIG=configs/yolov6n_finetune_cfg.py

# for new training use third-party/YOLOv6/configs/yolov6n.py
# this is the default
ARG TRAINING_CONFIG=third-party/YOLOv6/configs/yolov6n_finetune_cfg.py


# use ubuntu LTS (latest will pull LTS version)
FROM ubuntu

# redefine arg
ARG WORKSPACE
ARG DATASETS_DIR
ARG TRAINING_CONFIG

# update and install package
RUN   apt update \
	&&  apt upgrade --no-install-recommends --yes \
	&&  apt install \
		"build-essential" \
		"python3-dev" \
		"python3-virtualenv" \
		"cmake" \
		"patch" \
		"libgl1" \
		"libglib2.0-0t64" \
			--no-install-recommends --yes

# set current directory
WORKDIR ${WORKSPACE}

# copy the repository
COPY  .   .

# patch third-party/YOLOv6 repository
# because we don't have pushd and popd,
# we need to encapsulate patching in script
# since patching is directory sensitive
RUN	  <<EOF
set -e
set -x
cd "third-party/YOLOv6"
patch --verbose --forward -p1 < "../YOLOv6.patch"
EOF

# change permission of these third-party/YOLOv6 scripts to be executable:
# - tools/train.py
# - tools/infer.py
# - tools/load_test.py                                (optional)
# - deploy/RKNN/export_onnx_for_rknn.py               (optional)
#
# load_test.py and export_onnx_for_rknn.py are not originally from YOLOv6 repository
# it is added by patching
RUN    chmod --verbose ugoa+x,go-w  "third-party/YOLOv6/tools/train.py" \
	&& chmod --verbose ugoa+x,go-w  "third-party/YOLOv6/tools/infer.py" \
	&& chmod --verbose ugoa+x,go-w  "third-party/YOLOv6/tools/test_load.py" \
	&& chmod --verbose ugoa+x,go-w  "deploy/RKNN/export_onnx_for_rknn.py"

# do not immediately copy all repository content (current directory is repository directory)
# copy just requirements.txt file only
COPY   "requirements.txt"   "requirements.txt"

# copy patch file for requirements.txt
COPY   "requirements.txt.patch"   "requirements.txt.patch"

# patch requirements file
RUN   patch --verbose --forward -p1 < "requirements.txt.patch"

# create virtual environment in current workspace for ai training
# this pip install script is for pytorch and torchvision with gpu support (CUDA 12.8),
#        please see https://pytorch.org/ and change pip installation syntax for
#        torch and torchvision (and optionally torchaudio) to conform your host system
#        you can check your host system (CUDA version) with nvidia-smi, see
#        https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/sample-workload.html
# THIS VIRTUAL ENVIROMENT IS ONLY FOR TORCH AND TORCHVISION WHICH IS ONLY FOR AI TRAINING
RUN   python3 -m "virtualenv" --verbose --python "python3" --download "venv3" \
	&& . "venv3/bin/activate" \
	&& pip install --verbose torch torchvision \
	&& pip install --verbose -r "requirements.txt" \
	&& deactivate

# test if torch and torchvision is properly installed and can be run
COPY --chmod=755 <<EOF "check.py"
#!/usr/bin/env python
import torch
import torchvision
print(f"Torch version: {torch.__version__}")
print(f"Torchvision version: {torchvision.__version__}")
EOF

# run test (check.py)
RUN   . "venv3/bin/activate" \
	&& "./check.py" \
	&& deactivate

# create virtual environment only for rknn-toolkit2
# use requirements_rknn2.txt as requirement file
# THIS VIRTUAL ENVIRONMENT IS ONLY FOR CONVERTING TRAINING RESULT TO RKNN FORMAT
RUN   python3 -m "virtualenv" --verbose --python "python3" --download "venv3_rknn2" \
	&& . "venv3_rknn2/bin/activate" \
	&& pip install --verbose -r "requirements_rknn2.txt" \
	&& deactivate

# no testing for this virtual environment

# create wrapper script for training,
#    then convert pt file to onnx,
#    then convert onnx file to rknn file

COPY --chmod=755 <<EOF "1_do_ai_training.sh"
#!/bin/bash
set -e   # any error cause script to stop
set -x   # show what this script is doing
PROJECT_ROOT="${WORKSPACE}"

# activate python enviroment variable
. "\$PROJECT_ROOT/venv3/bin/activate"

# change directory to third-party/YOLOv6
cd "\$PROJECT_ROOT/third-party/YOLOv6"

# do training
"tools/train.py" \
	--data-path      "../../${DATASETS_DIR}/data.yaml" \
	--conf-file      "../../${TRAINING_CONFIG}"  \
	--img-size       640    \
	--batch-size     16     \
	--epochs         100    \
	--device         0      \
	--workers        2      \

# deactivate environment variable
deactivate
EOF

# create wrapper script for convert pt file to onnx file
# after training, pt file is in third-party/YOLOv6/runs:
#
# this is example tree for a training
# third-party/YOLOv6/runs
# `-- train
#     `-- exp
#         |-- args.yaml
#         |-- events.out.tfevents.1759832609.ea741857d245.12.0
#         |-- predictions.json
#         `-- weights
#             |-- best_ckpt.onnx
#             |-- best_ckpt.pt
#             |-- best_stop_aug_ckpt.pt
#             `-- last_ckpt.pt
#
# we use best_ckpt.pt as model
COPY --chmod=755 <<EOF "2_convert_pt_to_onnx.sh"
#!/bin/bash
set -e   # any error cause script to stop
set -x   # show what this script is doing
PROJECT_ROOT="${WORKSPACE}"

# activate python enviroment variable
. "\$PROJECT_ROOT/venv3/bin/activate"

# change directory to third-party/YOLOv6
cd "\$PROJECT_ROOT/third-party/YOLOv6"

# convert pt file to onnx
"deploy/RKNN/export_onnx_for_rknn.py" \
	--weights "runs/train/exp/weights/best_ckpt.pt" \
	--img-size "640" \
	--device 0

# deactivate environment variable
deactivate
EOF


# create wrapper script for convert onnx file to rknn file
COPY --chmod=755 <<EOF "3_convert_onnx_to_rknn.sh"
#!/bin/bash
set -e   # any error cause script to stop
set -x   # show what this script is doing
PROJECT_ROOT="${WORKSPACE}"

# activate python enviroment variable
. "\$PROJECT_ROOT/venv3_rknn2/bin/activate"

# change directory to third-party/rknn_model_zoo
cd "\$PROJECT_ROOT/third-party/rknn_model_zoo/examples/yolov6/python"

# file onnx
ONNX_FILE="../../../../YOLOv6/runs/train/exp/weights/best_ckpt.onnx"

# convert onnx file to rknn
python "convert.py" "\$ONNX_FILE" rk3588

# copy rknn file to runs directory file
mv --verbose --interactive \
	"\$PROJECT_ROOT/third-party/rknn_model_zoo/examples/yolov6/model/yolov6.rknn" \
	"\$PROJECT_ROOT/third-party/YOLOv6/runs/train/exp/weights/best_ckpt.rknn"

# deactivate environment variable
deactivate
EOF

# training result is in third-party/YOLOv6/runs
