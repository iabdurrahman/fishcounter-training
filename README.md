# fishcounter-training

---

## Overview

Welcome to Fishcounter Training repository!

This repository contains the tools needed to train the YOLOv6 model used for Xirka Fishcounter Device.

---

## How to Setup

### 1. Clone this repository

``` bash
# Cloen the repo
git clone git@github.com:ArvinNathanielTjong/fishcounter-training.git

# Install submodules
git submodule update --init --recursive
```

### 2. Setup the Python's Environment

Create a new virtual environment in this repository directory.

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

Run this script in the YOLOv6 directory

``` bash
python3 tools/train.py \
  --data-path <data-path> \
  --conf-file <conf-file> \
  --img-size 640 \
  --batch-size <batch-size> \
  --epochs <epoch>
```

| Param | Example |
|-|-|
| `<data-path>`   | `../../datasets/patin-dataset/data.yaml`    | 
| `<conf-file>`   | `../../configs/yolov6n_finetune_cfg.py`  |
| `<batch-size>`  | `16` |
| `<epoch>`       | `10` |

## How to Test your Model

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