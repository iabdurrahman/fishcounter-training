
Setup a new Virtual Environment in your machine.
``` bash
python3 -m venv venv
source venv/bin/activate
```
Install python dependencies here.
``` bash
pip install --upgrade pip
pip install -r requirements.txt
```

``` bash
cd third-party/YOLOv6
```
``` bash
python3 tools/train.py \
  --data-path ../../datasets/patin-dataset/data.yaml \
  --conf-file ../../configs/yolov6n_finetune_cfg.py \
  --img-size 640 \
  --batch-size 16 \
  --epochs 1
```