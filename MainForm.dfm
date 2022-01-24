object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'P4D ONNX TF MNIST Demo'
  ClientHeight = 507
  ClientWidth = 956
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 329
    Width = 956
    Height = 0
    Cursor = crVSplit
    Align = alTop
    ResizeStyle = rsUpdate
    ExplicitTop = 25
  end
  object HeaderControl1: THeaderControl
    Left = 0
    Top = 0
    Width = 956
    Height = 25
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Sections = <
      item
        Alignment = taCenter
        AutoSize = True
        ImageIndex = -1
        Text = 'Python Source code'
        Width = 956
      end>
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 25
    Width = 956
    Height = 304
    Align = alTop
    TabOrder = 1
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 280
      Height = 280
      Color = 14822282
      ParentColor = False
    end
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 280
      Height = 280
      Cursor = crCross
      Proportional = True
      OnMouseDown = Image1MouseDown
      OnMouseEnter = Image1MouseEnter
      OnMouseLeave = Image1MouseLeave
      OnMouseMove = Image1MouseMove
      OnMouseUp = Image1MouseUp
    end
    object btnRun: TButton
      Left = 169
      Top = 283
      Width = 105
      Height = 20
      Caption = 'Run Recognition'
      TabOrder = 0
      OnClick = btnRunClick
    end
    object sePythonCode: TSynEdit
      Left = 280
      Top = 0
      Width = 675
      Height = 279
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      TabOrder = 1
      UseCodeFolding = False
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Consolas'
      Gutter.Font.Style = []
      Highlighter = SynPythonSyn
      Lines.Strings = (
        '# -*- coding: utf-8 -*-'
        '"""'
        'Created on Thu Jan 20 08:04:53 2022'
        ''
        '@author: KoRiF'
        '"""'
        ''
        'import numpy as np'
        'import onnx'
        'from onnx import numpy_helper'
        'import os'
        'import glob'
        ''
        'os.environ['#39'TF_CPP_MIN_LOG_LEVEL'#39'] = '#39'3'#39' #avoid TF crash '
        'import tensorflow as backend'
        ''
        'import warnings'
        'import onnx_tf as xtf'
        'from onnx_tf.backend import prepare'
        ''
        ''
        ''
        'import cv2'
        ''
        'def image2input(image):'
        '    if isinstance(image, str):'
        '        image = cv2.imread(image) #'#39'input.png'#39
        '    elif not isinstance(image, np.ndarray):'
        '        image = np.array(image)    '
        '    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)'
        '    gray = cv2.resize(gray, (28,28)).astype(np.float32)/255'
        '    return np.reshape(gray, (1,1,28,28))'
        ''
        'diagnostic = True'
        ''
        ''
        'from delphi_module import delphi_form'
        ''
        'diagnostic = delphi_form.isPictureEmpty'
        ''
        ''
        ''
        'def selfdiagnostic():'
        '    test_data_dir = '#39'test_data_set_{ix}'#39
        
          '    test_num = len(glob.glob(os.path.join(path_to_model, test_da' +
          'ta_dir.format(ix='#39'*'#39'))))'
        '    '
        '    for no in range(test_num):'
        
          '        print('#39'-------------------------------------------------' +
          '-----\n'#39')'
        '    '
        
          '        test_data_path = os.path.join( path_to_model, test_data_' +
          'dir.format(ix=no))'
        
          '        print('#39'Experiment for dataset from "{folder}"'#39'.format(fo' +
          'lder=test_data_path))'
        '        '
        '        # Load inputs'
        '        inputs = []'
        
          '        inputs_num = len(glob.glob(os.path.join(test_data_path, ' +
          #39'input_*.pb'#39')))'
        '        for i in range(inputs_num):'
        
          '            input_file = os.path.join(test_data_path, '#39'input_{}.' +
          'pb'#39'.format(i))'
        '            tensor = onnx.TensorProto()'
        '            with open(input_file, '#39'rb'#39') as f:'
        '                tensor.ParseFromString(f.read())'
        '            inputs.append(numpy_helper.to_array(tensor))'
        '        '
        '        # Load reference outputs'
        '        ref_outputs = []'
        
          '        ref_outputs_num = len(glob.glob(os.path.join(test_data_p' +
          'ath, '#39'output_*.pb'#39')))'
        '        for i in range(ref_outputs_num):'
        
          '            output_file = os.path.join(test_data_path, '#39'output_{' +
          '}.pb'#39'.format(i))'
        '            tensor = onnx.TensorProto()'
        '            with open(output_file, '#39'rb'#39') as f:'
        '                tensor.ParseFromString(f.read())'
        '            ref_outputs.append(numpy_helper.to_array(tensor))'
        '        '
        '        # Run the model on the backend'
        '        '
        '        #outputs = list(backend.run_model(model, inputs))'
        '        outputs = tf_rep.run(inputs)'
        '        '
        '        '
        '        # Compare the results with reference outputs.'
        '        for ref_o, o in zip(ref_outputs, outputs):'
        '            print("result:", o)'
        '            print("reference output:", ref_o)'
        '            np.testing.assert_almost_equal(ref_o, o, 0)'
        
          '        print( np.argmax(ref_outputs), "recognized as: ", np.arg' +
          'max(outputs) )    '
        '        '
        'path_to_model = delphi_form.onnxDirectory '
        
          '#r'#39'c:\Users\KoRiF\Documents\Embarcadero\Studio\Projects\AI\ONNX\' +
          'Zoo\models\vision\classification\mnist\model\mnist'#39
        'model_filename = os.path.join( path_to_model, '#39'model.onnx'#39' )'
        '# onnx_model is an in-memory ModelProto'
        'onnx_model = onnx.load(model_filename)'
        ''
        'tf_rep = prepare(onnx_model)'
        ''
        'if diagnostic:'
        '    print(tf_rep.inputs) # Input nodes to the model'
        '    print('#39'-----'#39')'
        '    print(tf_rep.outputs) # Output nodes from the model'
        '    print('#39'-----'#39')'
        '    print(tf_rep.tensor_dict) # All nodes in the model'
        '    selfdiagnostic()'
        '    exit'
        ''
        'from io import BytesIO'
        'imagedata = BytesIO(bytes(delphi_form.PictureData))'
        ''
        'from PIL import Image'
        'img = Image.open(imagedata)'
        'img.show()'
        ''
        'img = image2input(img)'
        ''
        'inputs = [img]'
        'outputs = tf_rep.run(inputs) '
        'print(outputs)'
        'print( "recognized as: ", np.argmax(outputs) )'
        ''
        'delphi_form.RecognizedValue =  int(np.argmax(outputs))'
        ''
        '')
    end
    object ButtonClear: TButton
      Left = 0
      Top = 283
      Width = 105
      Height = 20
      Caption = 'Clear'
      TabOrder = 2
      OnClick = ButtonClearClick
    end
    object ButtonSelectONNX: TButton
      Left = 576
      Top = 283
      Width = 195
      Height = 20
      Caption = 'Select ONNX MNIST Directory...'
      TabOrder = 3
      OnClick = ButtonSelectONNXClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 334
    Width = 956
    Height = 173
    Align = alBottom
    TabOrder = 2
    object HeaderControl2: THeaderControl
      Left = 1
      Top = 1
      Width = 954
      Height = 17
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Sections = <
        item
          Alignment = taCenter
          AutoSize = True
          ImageIndex = -1
          Text = 'Python Output'
          Width = 954
        end>
      ParentFont = False
      ExplicitLeft = 0
      ExplicitTop = 73
    end
    object mePythonOutput: TMemo
      Left = 1
      Top = 19
      Width = 954
      Height = 153
      Align = alBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      ExplicitTop = 16
    end
  end
  object SynPythonSyn: TSynPythonSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 760
    Top = 32
  end
  object SynEditPythonBehaviour: TSynEditPythonBehaviour
    Editor = sePythonCode
    Left = 760
    Top = 80
  end
  object PythonEngine: TPythonEngine
    DllPath = 'c:\ProgramData\Anaconda3\'
    OnBeforeLoad = PythonEngineBeforeLoad
    IO = PythonGUIInputOutput
    Left = 880
    Top = 32
  end
  object PythonGUIInputOutput: TPythonGUIInputOutput
    UnicodeIO = True
    RawOutput = False
    Output = mePythonOutput
    Left = 880
    Top = 80
  end
  object PyDelphiWrapper1: TPyDelphiWrapper
    Engine = PythonEngine
    Module = PythonModule1
    Left = 208
    Top = 49
  end
  object PythonModule1: TPythonModule
    Engine = PythonEngine
    ModuleName = 'delphi_module'
    Errors = <>
    Left = 208
    Top = 113
  end
end
