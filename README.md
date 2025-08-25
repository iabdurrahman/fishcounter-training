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

### ROBOFLOW TUTORIAL

go to https://app.roboflow.com/

links to learn how to use roboflow : https://roboflow.com/learn 

download the raw dataset for YOLOv6 

---

### notes : make sure you change the config file pretrained path to the model that you want to continue training

### change somethings in the datasets : 

go to the data.yaml of your dataset and make sure the path is ,correct 
example : 

```
train: ../../datasets/patin-flow-dataset/images/train
val: ../../datasets/patin-flow-dataset/images/valid
test: ../../datasets/patin-flow-dataset/images/test

is_coco: False #add this to the yaml file!

```




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

### EXPLANATION (THE NUMBER 4 from the link above)

```shell
cd python
python convert.py <onnx_model> <TARGET_PLATFORM> <dtype(optional)> <output_rknn_path(optional)>

# such as: 
python convert.py ../model/yolov6n.onnx rk3588
# output model will be saved as ../model/yolov6.rknn
```

*Description:*

- `<onnx_model>`: Specify ONNX model path.
- `<TARGET_PLATFORM>`: Specify NPU platform name.  Such as 'rk3588'.
- `<dtype>(optional)`: Specify as `i8`, `u8` or `fp`. `i8`/`u8` for doing quantization, `fp` for no quantization. Default is `i8`.
- `<output_rknn_path>(optional)`: Specify save path for the RKNN model, default save in the same directory as ONNX model with name `yolov6.rknn`
---



