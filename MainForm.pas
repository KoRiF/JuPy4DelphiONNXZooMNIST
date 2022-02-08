unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, SynEdit, Vcl.StdCtrls,
  PythonEngine, PythonGUIInputOutput, SynEditPythonBehaviour,
  SynEditHighlighter, SynEditCodeFolding, SynHighlighterPython,
  WrapDelphi,
  Vcl.ExtCtrls, Vcl.Mask, Vcl.Menus;

type
  TForm1 = class(TForm)
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
    sePythonCode: TSynEdit;

    PageControl1: TPageControl;
    TabSheetJupyter: TTabSheet;
    TabSheetRecognition: TTabSheet;
    SynEditRecognizers: TSynEdit;
    TabSheetRecognizers: TTabSheet;
    SynEditRecognize: TSynEdit;
    Image1: TImage;
    ButtonRecognize: TButton;
    ButtonClear: TButton;
    ButtonSelectONNX: TButton;
    ComboBox1: TComboBox;
    LabeledEditJupyToken: TLabeledEdit;
    LabeledEditJupyFilePath: TLabeledEdit;
    PythonModule1: TPythonModule;
    PyDelphiWrapper1: TPyDelphiWrapper;
    CheckBoxStripCellCode: TCheckBox;
    PopupMenuJuPy4D: TPopupMenu;
    WrapasPyDelphionly1: TMenuItem;
    WrapasJupyterOnly1: TMenuItem;
    StripselectedfromJupyterOnly1: TMenuItem;
    StripselectedfromDelphiOnly1: TMenuItem;
    procedure btnRunClick(Sender: TObject);
    procedure PythonEngineBeforeLoad(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonRecognizeClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Image1MouseLeave(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonClearClick(Sender: TObject);
    procedure SynEditRecognizersMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SynEditRecognizeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WrapasPyDelphionly1Click(Sender: TObject);
    procedure WrapasJupyterOnly1Click(Sender: TObject);
    procedure StripselectedfromJupyterOnly1Click(Sender: TObject);
    procedure StripselectedfromDelphiOnly1Click(Sender: TObject);
  private
    { Private declarations }
    drawingNow: Boolean;
    _isPictureEmpty: boolean;
    _backendSwitchTag: string;
    _value: Integer;
    _ONNXDir: String;
    jupyCells: TDictionary<String, String>;
    selectedJuPyCode: string;

    procedure noteSelectedPyCode(SynEdit: TSynEdit);
    procedure replaceSelectedPyCode(SynEdit: TSynEdit; replacementCode: string);
    function getJupyToken: string;
    const COLOR_BACKGROUND: TColor = clBackground;
    const COLOR_PEN: TColor = clOlive;
    procedure ClearPicture();
    function getPictureData(): TArray<Byte>;
    function getJupyFilepath(): string;
    function getJupySocket(): string;
  public
    { Public declarations }
    property onnxDirectory: string read _ONNXDir;
    property isPictureEmpty: boolean read _isPictureEmpty;
    property PictureData: TArray<Byte> read getPictureData;
    property backendSwitchTag: string read _backendSwitchTag;
    property RecognizedValue: Integer write _value;
    property jupyFilepath: string read getJupyFilepath;
    property jupyToken: string read getJupyToken;
    property jupySocket: string read getJupySocket;
    procedure addJupyCellCode(code: string);
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
  System.Math,
  UnitPy4DUtils;

const
  defaultDir = 'c:\Users\KoRiF\Documents\Embarcadero\Studio\Projects\AI\ONNX\Zoo\models\vision\classification\mnist\model\mnist\';
  defaultHttpSocket = 'http://localhost:8888';

procedure TForm1.addJupyCellCode(code: string);
begin
  var celltext := code;
  var cellkey := extractJuPyCellKey(code);
  jupyCells.AddOrSetValue(cellkey, code);
end;

procedure TForm1.btnRunClick(Sender: TObject);
begin
  try
//PythonEngine.LoadDll;
    PythonEngine.ExecString(UTF8Encode(sePythonCode.Text));
    var codeRecognizerClasses := '';
    if jupyCells.TryGetValue('ONNX-based recognizers', codeRecognizerClasses) then
    begin
      if CheckBoxStripCellCode.Checked then
        codeRecognizerClasses := includeDelphiInteraction(codeRecognizerClasses);
      SynEditRecognizers.Text := codeRecognizerClasses;
    end;

    var codeRecognizeApp := '';
    if jupyCells.TryGetValue('application', codeRecognizeApp) then
    begin
      if CheckBoxStripCellCode.Checked then
        codeRecognizeApp := includeDelphiInteraction(codeRecognizeApp);
      SynEditRecognize.Text := codeRecognizeApp;
    end;
    ShowMessage('Successfully attached to the Jupyter Notebook!');

  except on Ex: EPySystemExit do
  end;
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  ClearPicture();
  _isPictureEmpty := True;
end;

procedure TForm1.ButtonRecognizeClick(Sender: TObject);
var
  pictBytes : TBytesStream;
begin
  try
    PythonEngine.ExecString(UTF8Encode(SynEditRecognizers.Text));
    PythonEngine.ExecString(UTF8Encode(SynEditRecognize.Text));

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
  _backendSwitchTag := 'ONNX Runtime';

  jupyCells := TDictionary<String, String>.Create();
end;

function TForm1.getJupyFilepath: string;
begin
  RESULT := LabeledEditJupyFilePath.Text;
end;

function TForm1.getJupySocket: string;
begin
  RESULT := defaultHttpSocket;
end;

function TForm1.getJupyToken: string;
begin
  RESULT := LabeledEditJupyToken.Text;
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

procedure TForm1.noteSelectedPyCode(SynEdit: TSynEdit);
begin
  var start := SynEdit.SelStart;
  var fin := SynEdit.SelEnd;
  selectedJuPyCode := SynEdit.Text.Substring(start, fin - start);
end;

procedure TForm1.replaceSelectedPyCode(SynEdit: TSynEdit; replacementCode: string);
begin
  var start := SynEdit.SelStart;
  var fin := SynEdit.SelEnd;
  var l0 := fin - start;
  var ll := Length(replacementCode);
  var originalCode := SynEdit.Text;
  SynEdit.Text := originalCode.Substring(0, start - 1) + replacementCode + originalCode.Substring(fin + 1);

end;

procedure TForm1.StripselectedfromDelphiOnly1Click(Sender: TObject);
begin
  var Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  var SynEdit := Caller as TSynEdit;

  var LRLF := configureLineBreak(#$D#$A);
  var strippedCode := wrapAsPyDelphiOnly(selectedJuPyCode, true);
  replaceSelectedPyCode(SynEdit, strippedCode);
  configureLineBreak(LRLF);
end;

procedure TForm1.StripselectedfromJupyterOnly1Click(Sender: TObject);
begin
  var Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  var SynEdit := Caller as TSynEdit;

  var LRLF := configureLineBreak(#$D#$A);
  var strippedCode := wrapAsJuPyOnly(selectedJuPyCode, true);
  replaceSelectedPyCode(SynEdit, strippedCode);
  configureLineBreak(LRLF);
end;

procedure TForm1.SynEditRecognizeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    noteSelectedPyCode(SynEditRecognize);
end;

procedure TForm1.SynEditRecognizersMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    noteSelectedPyCode(SynEditRecognizers);
end;

procedure TForm1.WrapasJupyterOnly1Click(Sender: TObject);
begin
  var Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  var SynEdit := Caller as TSynEdit;

  var LRLF := configureLineBreak(#$D#$A);
  var wrappedCode := wrapAsJuPyOnly(selectedJuPyCode);
  replaceSelectedPyCode(SynEdit, wrappedCode);
  configureLineBreak(LRLF);
end;

procedure TForm1.WrapasPyDelphionly1Click(Sender: TObject);
begin
  var Caller := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  var SynEdit := Caller as TSynEdit;

  var LRLF := configureLineBreak(#$D#$A);
  var wrappedCode := wrapAsPyDelphiOnly(selectedJuPyCode);
  replaceSelectedPyCode(SynEdit, wrappedCode);
  configureLineBreak(LRLF);
end;

procedure TForm1.PythonEngineBeforeLoad(Sender: TObject);
begin
  PythonEngine.SetPythonHome('C:\ProgramData\Anaconda3');
end;



begin
  MaskFPUExceptions(True);
end.
