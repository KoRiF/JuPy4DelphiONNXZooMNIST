unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, SynEdit, Vcl.StdCtrls,
  PythonEngine, PythonGUIInputOutput, SynEditPythonBehaviour,
  SynEditHighlighter, SynEditCodeFolding, SynHighlighterPython, Vcl.ExtCtrls,
  WrapDelphi;

type
  TForm1 = class(TForm)
    sePythonCode: TSynEdit;
    HeaderControl1: THeaderControl;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    HeaderControl2: THeaderControl;
    mePythonOutput: TMemo;
    SynPythonSyn: TSynPythonSyn;
    SynEditPythonBehaviour: TSynEditPythonBehaviour;
    PythonEngine: TPythonEngine;
    PythonGUIInputOutput: TPythonGUIInputOutput;
    btnRun: TButton;
    PaintBox1: TPaintBox;
    ButtonClear: TButton;
    Image1: TImage;
    PyDelphiWrapper1: TPyDelphiWrapper;
    PythonModule1: TPythonModule;
    ButtonSelectONNX: TButton;
    procedure btnRunClick(Sender: TObject);
    procedure PythonEngineBeforeLoad(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseLeave(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonSelectONNXClick(Sender: TObject);


  private
    { Private declarations }
    drawingNow: Boolean;
    _isPictureEmpty: boolean;
    _value: Integer;
    _ONNXDir: String;
    const COLOR_BACKGROUND: TColor = clBackground;
    const COLOR_PEN: TColor = clOlive;
    procedure ClearPicture();
    function getPictureData(): TArray<Byte>;
  public
    { Public declarations }
    property onnxDirectory: string read _ONNXDir;
    property isPictureEmpty: boolean read _isPictureEmpty;
    property PictureData: TArray<Byte> read getPictureData;
    property RecognizedValue: Integer write _value;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  FileCtrl,
  WrapDelphiVCL,
  System.Rtti,
  System.Threading,
  System.Math;

const
  defaultDir = 'c:\Users\KoRiF\Documents\Embarcadero\Studio\Projects\AI\ONNX\Zoo\models\vision\classification\mnist\model\mnist\';

procedure TForm1.btnRunClick(Sender: TObject);
var
  pictBytes : TBytesStream;
begin
  //passPicture();
  try
    PythonEngine.ExecString(UTF8Encode(sePythonCode.Text));
  except on Ex: EPySystemExit do
    begin
      var code := Ex.EValue;
      if (code='') or (code='0') then
      begin
        ShowMessage('Diagnostic success');
        exit;
      end
      else raise Ex;
    end;
  end;
  ShowMessage('Recognized value is: ' + IntToStr(_value));
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  ClearPicture();
  _isPictureEmpty := True;
end;

procedure TForm1.ButtonSelectONNXClick(Sender: TObject);
var directories: TArray<String>;
begin
  directories := TArray<String>.Create();
  var ok := FileCtrl.SelectDirectory(_ONNXDir,directories, [], 'Select ONNX Model Directory'); //TSelectDirFileDlgOpts
  if ok then
  begin
    if (Length(directories)>0) and DirectoryExists(directories[0]) then
      _ONNXDir := directories[0];
  end;

end;

procedure TForm1.ClearPicture;
begin
  Image1.Canvas.Pen.Color := COLOR_BACKGROUND;
  Image1.Canvas.Brush.Color := COLOR_BACKGROUND;
  Image1.Canvas.FillRect(Rect(0,0,Image1.Height,Image1.Width));
  Image1.Canvas.Pen.Color := COLOR_PEN;
  Image1.Canvas.Brush.Color := COLOR_PEN;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  var Py := PyDelphiWrapper1.Wrap(Form1);
  PythonModule1.SetVar('delphi_form', Py);
  PythonEngine.Py_DECREF(Py);

  drawingNow := False;
  ClearPicture();
  _isPictureEmpty := true;

  Image1.Canvas.Pen.Width := 10;
  _ONNXDir := defaultDir;
end;

function TForm1.getPictureData: TArray<Byte>;
var
  pictBytes : TBytesStream;
begin
  pictBytes := TBytesStream.Create;
  Image1.Picture.SaveToStream(pictBytes);
  RESULT := pictBytes.Bytes;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
  Image1.Canvas.MoveTo(x, y);
  drawingNow := True;
end;

procedure TForm1.Image1MouseEnter(Sender: TObject);
begin
  drawingNow := False;
end;

procedure TForm1.Image1MouseLeave(Sender: TObject);
begin
  drawingNow := False;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if drawingNow then
  begin
    Image1.Canvas.LineTo(x, y);
    _isPictureEmpty := False;
  end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  drawingNow := False;
end;

procedure TForm1.PythonEngineBeforeLoad(Sender: TObject);
begin
  PythonEngine.SetPythonHome('C:\ProgramData\Anaconda3');
end;

begin
  MaskFPUExceptions(True);
end.
