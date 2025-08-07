# fishcounter-training

---

## Overview

Welcome to Fishcounter Training repository!

This repository contains the tools needed to train the YOLOv6 model used for Xirka Fishcounter Device.

---

## How to Setup

### 1. Clone this repository

``` bash
# Clone the repo
git clone https://github.com/ArvinNathanielTjong/fishcounter-training.git



# Install submodules
git submodule update --init --recursive
```

### 2. Setup the Python's Environment 

Create a new virtual environment in this repository directory. (optional)

``` bash
python3 -m venv venv
```

Whenever you want to use the venv, run this in your terminal.
``` bash
source venv/bin/activate 
```

Install python dependencies inside the repository.
``` bash
pip install --upgrade pip
pip install -r requirements.txt
```


## How to Train your Model

### notes : make sure you change the config file pretrained path to the model that you want to continue training



Run this script in the YOLOv6 directory (ubuntu)

``` bash
python3 tools/train.py \
  --data-path <data-path> \
  --conf-file <conf-file> \
  --img-size 640 \
  --batch-size <batch-size> \
  --epochs <epoch> \
  --device 0
```

Run this script in the YOLOv6 directory (windows)

``` bash
python -m tools.train --data-path <data-path> --conf-file <conf-file> --img-size 640 --batch-size <batch-size> --epochs <epoch> --device 0
```

| Param | Example |
|-|-|
| `<data-path>`   | `../../datasets/patin-dataset/data.yaml`    | 
| `<conf-file>`   | `../../configs/yolov6n_finetune_cfg.py`  |
| `<batch-size>`  | `16` |
| `<epoch>`       | `100` | 

notes : if you want to use a purely new model use the conf file built in to yolov6 which is in the 
```
"YOLOv6/configs/yolov6n.py"
```
because there are no pretrained (None)

find your trained pt file in the run directory

## How to Test your Model (optional)

Run this script in the YOLOv6 directory

```
python3 tools/infer.py \
  --weight <weight-path> \
  --yaml <yaml-file> \
  --webcam \
  --conf-thres 0.1 \
  --webcam-addr /dev/video0 \
  --view-img
```

| Param | Example |
|-|-|
| `<weight-path>` | `../../runs/exp3/weights/best_ckpt.pt`    | 
| `<yaml-file>`   | `../../datasets/patin-dataset/data.yaml`  |




## PT file -> ONNX
```
pip install torch onnx
```
Then follow the instruction inside the file called ONNX_RKNNexport.ipynb

notes : don't lose the onnx file (save it)

## 🧠 RKNN Setup (For NPU)

### DO THIS IN UBUNTU 


```bash
sudo apt-get update
sudo apt-get install cmake
pip3 install rknn-toolkit2
```

notes : in the link below you need to gitclone the whole git first 

THE CLONE IS ALREADY AVAILABLE AT THE THIRD PARTY FOLDER (CHECK IT !) 

```
git clone https://github.com/airockchip/rknn_model_zoo.git
```
go to the directory of 
```
/rknn_model_zoo/examples/yolov6/python
```
---

follow step number 4 below :

Convert ONNX to RKNN:  
🔗 https://github.com/airockchip/rknn_model_zoo/tree/main/examples/yolov6

### OR
follow this but make sure the path is correct
``` bash
python convert.py ../../../../../models/onnxfile/best_ckpt.onnx rk3588

```

---
