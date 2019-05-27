#!/bin/bash

# Remember to first configure awscli with credentials before running this file
set -e

# Clone repo
echo Cloning repo...
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
git clone https://github.com/danamyu/mask_rcnn_nucleus.git ##TODO: update to your own github repo

# Copy datasets from s3
echo Copying dataset...
mkdir -p ./Mask_RCNN/samples/nuc/datasets
#mkdir -p ./Mask_RCNN/samples/nuc/datasets/train_val
mkdir -p ./Mask_RCNN/samples/nuc/datasets/train
#mkdir -p ./Mask_RCNN/samples/nuc/datasets/val
mkdir -p ./Mask_RCNN/samples/nuc/datasets/test
aws s3 cp s3://class1af37499e-e69c-408c-b262-4cfa804d19c3/mask_rcnn_nucleus/stage1_train.zip ./Mask_RCNN/samples/nuc/datasets/train/
aws s3 cp s3://class1af37499e-e69c-408c-b262-4cfa804d19c3/mask_rcnn_nucleus/stage1_train_labels.csv ./Mask_RCNN/samples/nuc/datasets/test/
#echo Unziping train_nuc_segmentations...
#unzip ./Mask_RCNN/samples/nuc/datasets/train_val/train_nuc_segmentations.csv.zip -d ./Mask_RCNN/samples/nuc/datasets/train/
echo Unziping train images...
unzip -q ./Mask_RCNN/samples/nuc/datasets/train/stage1_train.zip -d ./Mask_RCNN/samples/nuc/datasets/train/


# Gets the latest folder and make the same directory locally
# nucleus20190521T1402/
LATEST_DIR=`aws s3 ls s3://mask_rcnn_nucleus/logs/ | grep / | sort | tail -n 1 | awk '{print $2}'` #TODO: upload latest train directory to logs
mkdir -p ./Mask_RCNN/logs/$LATEST_DIR

# Gets the latest file from the latest directory in weights
# logs/nucleus20190521T1402/mask_rcnn_nucleus_0004.h5
KEY=`aws s3 ls s3://mask_rcnn_nucleus/logs/ --recursive | sort | tail -n 1 | awk '{print $4}'`
echo "Downloading weights... $KEY"
aws s3 cp s3://mask_rcnn_nucleus/$KEY ./Mask_RCNN/$KEY


# Split dataset into train and val folders
#echo Splitting train and val sets...
#cd ./Mask_RCNN/samples/ship
#python3 split_train_val.py

echo Done with setup!

# Log into ecr and pull image
# $(aws ecr get-login --no-include-email --region eu-central-1)
# docker pull 001413338534.dkr.ecr.us-east-1.amazonaws.com/deep-learning-gpu:latest

# Command to run docker here for convenience as a comment
# docker run -it -p 8888:8888 -p 6006:6006 -v ~/.:/host 001413338534.dkr.ecr.us-east-1.amazonaws.com/deep-learning-gpu #TODO: update host
# docker run 001413338534.dkr.ecr.us-east-1.amazonaws.com/deep-learning-gpu python train.sh #TODO: update host
