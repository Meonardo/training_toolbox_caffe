### Install Caffe with OpenVINO and OpenCV support on Ubuntu 20.04
```bash
export https_proxy=http://172.16.30.188:7891 http_proxy=http://172.16.30.188:7891 all_proxy=socks5://172.16.30.188:7891
```

### URLs for downloading
- wget https://github.com/Kitware/CMake/archive/refs/tags/v3.22.0.tar.gz
- wget https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.19.1.tar.gz
- git clone -b v2022.3.0 https://github.com/openvinotoolkit/openvino.git --recursive
- wget https://github.com/opencv/opencv/archive/refs/tags/4.8.0.tar.gz

### Instructions
1. Update CMake to 3.22.0 or above
2. Build protobuf v3.19.1:
   1. download the source code from above url;
   2. build protobuf:
      ```bash
      ./autogen.sh
      ./configure --prefix=/home/meonardo/opt/protobuf
      make
      make install
      ```
   3. export protobuf path:
      ```bash
      echo 'export PATH=/home/meonardo/opt/protobuf/bin:$PATH' >> ~/.bashrc
      echo 'export LD_LIBRARY_PATH=/home/meonardo/opt/protobuf/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
      echo 'export PKG_CONFIG_PATH=/home/meonardo/opt/protobuf/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc
      source ~/.bashrc
      ```   
3. Build OpenVINO 2022.3: 
   `cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_SAMPLES=Off -DCMAKE_INSTALL_PREFIX=/home/meonardo/opt/intel`

4. Build OpenCV(4.8.0) with OpenVINO: 
   1. Apply OpenVINO env first, run: `source /home/meonardo/opt/intel/setupvars.sh`
   2. `cmake -B build -DCMAKE_BUILD_TYPE=Release -DWITH_OPENVINO=ON -DWITH_FFMPEG=ON -DNGRAPH=ON -DCMAKE_INSTALL_PREFIX=/home/meonardo/opt/intel/`

5. Build Caffe
   - install requirements:
      ```bash
      pip install -r caffe/python/requirements.txt
      sudo apt install -y libcudnn8=8.9.7.29-1+cuda11.8 libcudnn8-dev=8.9.7.29-1+cuda11.8
      more apt installation see the docker file.
      ```
   - ```bash
      cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="/home/meonardo/opt/intel;/home/meonardo/opt/protobuf" \
         -DCMAKE_INSTALL_PREFIX=/home/meonardo/opt/caffe \
         -Dpython_version=3 -Wno-dev -DCMAKE_CXX_FLAGS="-std=c++14" \
         -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
         -DCUDA_ARCH_BIN="86" \
         -DCUDA_ARCH_PTX="86" \
         -DCUDA_ARCH_NAME="Manual" \
         -DOpenCV_DIR=/home/meonardo/opt/intel/lib/cmake
     ``` 
   - export paths:
      ```bash
      echo 'export PATH=/home/meonardo/opt/caffe/bin:$PATH' >> ~/.bashrc
      echo 'export LD_LIBRARY_PATH=/home/meonardo/opt/caffe/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
      echo 'export PYTHONPATH=/home/meonardo/opt/caffe/python:$PYTHONPATH' >> ~/.bashrc
      source ~/.bashrc
      ```    


6. Train with Caffe
   ```bash
   export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
   caffe train --solver=./solver.prototxt --weights=../../init_weights/action_detection_0005.caffemodel 2>&1 | tee ../../train/import_trace.log
   ```

7. Test if Caffe works fine
   ```bash
   python3 - <<'PY'
   import os, caffe
   os.environ["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python"
   solver = caffe.get_solver("/mnt/workspace/models/person_detection_action_recognition/solver.prototxt")
   solver.step(1)  # one iteration just to cross data layer + forward/backward once
   print("step(1) OK")
   PY
   ```

### Caffe configurations
```
   -- Caffe_DEFINITIONS: PUBLIC;-DUSE_LMDB;PUBLIC;-DUSE_LEVELDB;PUBLIC;-DUSE_CUDNN;PUBLIC;-DUSE_OPENCV;PRIVATE;-DWITH_PYTHON_LAYER
   -- Caffe_COMPILE_OPTIONS: 
   -- 
   -- ******************* Caffe Configuration Summary *******************
   -- General:
   --   Version           :   1.0.0
   --   Git               :   6f82cb36-dirty
   --   System            :   Linux
   --   C++ compiler      :   /usr/bin/c++
   --   Release CXX flags :   -O3 -DNDEBUG -std=c++14 -fPIC -Wall -Wno-sign-compare -Wno-uninitialized
   --   Debug CXX flags   :   -g -std=c++14 -fPIC -Wall -Wno-sign-compare -Wno-uninitialized
   --   Build type        :   Release
   -- 
   --   BUILD_SHARED_LIBS :   ON
   --   BUILD_python      :   ON
   --   BUILD_matlab      :   OFF
   --   BUILD_docs        :   ON
   --   CPU_ONLY          :   OFF
   --   USE_OPENCV        :   ON
   --   USE_LEVELDB       :   ON
   --   USE_LMDB          :   ON
   --   USE_NCCL          :   OFF
   --   ALLOW_LMDB_NOLOCK :   OFF
   -- 
   -- Dependencies:
   --   BLAS              :   Yes (Atlas)
   --   Boost             :   Yes (ver. 1.71)
   --   glog              :   Yes
   --   gflags            :   Yes
   --   protobuf          :   Yes (ver. ..)
   --   lmdb              :   Yes (ver. 0.9.24)
   --   LevelDB           :   Yes (ver. 1.22)
   --   Snappy            :   Yes (ver. 1.1.8)
   --   OpenCV            :   Yes (ver. 4.8.0)
   --   CUDA              :   Yes (ver. 11.8)
   -- 
   -- NVIDIA CUDA:
   --   Target GPU(s)     :   Manual
   --   GPU arch(s)       :   sm_86 compute_86
   --   cuDNN             :   Yes (ver. 8.9.7)
   -- 
   -- Python:
   --   Interpreter       :   /home/meonardo/miniconda3/envs/caffe/bin/python3 (ver. 3.8.20)
   --   Libraries         :   /home/meonardo/miniconda3/envs/caffe/lib/libpython3.8.so (ver 3.8.20)
   --   NumPy             :   /home/meonardo/.local/lib/python3.8/site-packages/numpy/core/include (ver 1.24.4)
   -- 
   -- Documentaion:
   --   Doxygen           :   No
   --   config_file       :   
   -- 
   -- Install:
   --   Install path      :   /home/meonardo/opt/caffe
   -- 
   -- Configuring done
```

### Debug Caffe loading issues
   ```
   LD_DEBUG=libs caffe train --solver /path/to/solver.prototxt 2>&1 \ > | grep -E 'libprotobuf|libstdc\+\+|cv2|_caffe|libcaffe.so' | head -n 120

   or 

   ltrace -f -e dlopen -s 256 caffe train --solver /path/to/solver.prototxt 2>&1 \ > | grep -i 'xxx'
   ```