# MNIST_ONNX_Py4Delphi
Demo: use MNIST datamodel from the ONNX Zoo over Py4Delphi for the manual input recognition and integration with Jupyter Notebook
https://github.com/onnx/models/tree/main/vision/classification/mnist



## Prerequirements:
 
1. Clone ONNX Models Zoo from https://github.com/onnx/models
2. Load MNIST model
ONNX version = 1.3 Opset version 8 
i.e. https://github.com/onnx/models/blob/main/vision/classification/mnist/model/mnist-8.tar.gz
3. Follow https://github.com/onnx/models/blob/main/README.md#usage- for ONNX models install details 
4. Unpacked MNIST model.onnx must be available at $ONNXZoo\models\vision\classification\mnist\model\mnist\
5. Install Anaconda.
6. Install Jupyter Notebook
7. TensorFlow and ONNX Runtime packages should be installed 
8. Install Delphi 11 https://www.embarcadero.com/products/delphi/starter
9. Install Python4Delphi https://github.com/pyscripter/python4delphi

## Install

1. Add environment variable $ONNXZoo with the path to the directory containing cloned ONNX models repo
2. Add environment variable $PYANACONDAHOME containing the path to Anaconda home directory ("C:\ProgramData\Anaconda3")
3  Clone this repo
4. [Optional] Put AnacondaProjects/ONNXNotebook.ipynb in the user home directory

## Usage
1. Run Jupyter Notebook and open ONNXNotebook.ipynb file
2. You can edit script in the cells and save it
3. Run Delphi App 
4. Run Anaconda Prompt and enter 'jupyter notebook list' comand
5. Copy the Jupyter Notebook token and paste it in the 'Jupyter Notebook Token' field on the 'Jupyter' tab
6. After press the 'Run' button the success message should appear 
and python code should be loaded from ONNXNotebook cells to the Python script editors on the 'ONNX Recognizers' & 'Recognition' tabs
7. You can switch between recognizers using 'Select ML backend...' combobox
8. You can draw any digit at the area on the 'Recognize' tab and click 'Recognize!'.
