#!/usr/bin/env bash

set -e

# Apply OpenVINO environment
source ~/opt/intel/setupvars.sh 

# This is needed if OpenCV or OpenVINO is built with a different protobuf version
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

export PATH=/home/meonardo/opt/caffe/bin:$PATH
export LD_LIBRARY_PATH=/home/meonardo/opt/caffe/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/home/meonardo/opt/caffe/python:$PYTHONPATH

# Get current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Current dir $SCRIPT_DIR"

cd $SCRIPT_DIR/../models/person_detection_action_recognition_2_classes

# Start training
caffe train \
    --solver=./solver.prototxt \
    --weights=../../init_weights/action_detection_0005.caffemodel \
    2>&1 | tee ../../train/import_trace.log