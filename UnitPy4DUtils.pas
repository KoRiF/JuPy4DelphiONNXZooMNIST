unit UnitPy4DUtils;

interface

type
  TPythonCodeAdapter = Class
  private
    const
      PYTHONLONGCOMMENT = '####';
      CELLKEY = '$';

      PYLONGMULTYDOCSTRING0 = '"""';
      PYLONGMULTYDOCSTRING1 = '''''''';

      PYCOMMENT0BEGIN = PYLONGMULTYDOCSTRING0 + '%';
      PYCOMMENT0END =   '%' + PYLONGMULTYDOCSTRING0;

      PYCOMMENT1BEGIN = PYLONGMULTYDOCSTRING1 + '$';
      PYCOMMENT1END =   '$' + PYLONGMULTYDOCSTRING1;
    var
      _RET_ : string;
    property RET: string read _RET_ write _RET_;


    function PYDELPHIONLYBEGIN: string;
    function PYDELPHIONLYEND: string;
    function PYNODELPHIBEGIN: string;
    function PYNODELPHIEND: string;

    procedure wrap(var pythoncode: string; preWrap, postWrap: string);
    procedure strip(var pythoncode: string; preWrap, postWrap: string);
    procedure setDelphiInteraction(var pythoncode: string; active: boolean);
    procedure setNativePyInteraction(var pythoncode: string; active: boolean);
  public
    constructor Create(lineBreak: string);
    function includeDelphiInteraction(pythoncode: string): string;
    function excludeDelphiInteraction(pythoncode: string): string;
    function wrapAsPyDelphiOnly(pythoncode: string; stripping: boolean=False): string;
    function wrapAsJuPyOnly(pythoncode: string; stripping: boolean=False): string;

    function extractTopLine(text: string): string;
    function extractJuPyCellKey(celltext: string): string;
  End;

  function includeDelphiInteraction(pythoncode: string): string;
  function excludeDelphiInteraction(pythoncode: string): string;
  function wrapAsPyDelphiOnly(pythoncode: string; stripping: boolean=False): string;
  function wrapAsJuPyOnly(pythoncode: string; stripping: boolean=False): string;

  procedure rewrapping(var code: string; commentline, comment2line: string; wrap: boolean);

  function extractTopLine(text: string): string;
  function extractJuPyCellKey(celltext: string): string;

  function configureLineBreak(ret: string): string;
implementation
uses SysUtils, StrUtils;

var
  PyCoder: TPythonCodeAdapter;


function configureLineBreak(ret: string): string;
begin
  RESULT := PyCoder.RET;
  PyCoder.RET := ret;
end;

function includeDelphiInteraction(pythoncode: string): string;
begin
  RESULT := PyCoder.includeDelphiInteraction(pythoncode);
end;

function excludeDelphiInteraction(pythoncode: string): string;
begin
  RESULT := PyCoder.excludeDelphiInteraction(pythoncode);
end;

function wrapAsPyDelphiOnly(pythoncode: string; stripping: boolean): string;
begin
  RESULT := PyCoder.wrapAsPyDelphiOnly(pythoncode, stripping);
end;
function wrapAsJuPyOnly(pythoncode: string; stripping: boolean): string;
begin
  RESULT := PyCoder.wrapAsJuPyOnly(pythoncode, stripping);
end;

procedure rewrapping(var code: string; commentline, comment2line: string; wrap: boolean);
var orig, target: string;
begin
  if wrap then
  begin
    orig := commentline;
    target := comment2line;
  end
  else
  begin
    orig := comment2line;
    target := commentline;
  end;

  code := StringReplace(code, orig, target, [rfReplaceAll]);
end;


function extractTopLine(text: string): string;
begin
  RESULT := PyCoder.extractTopLine(text);
end;

function extractJuPyCellKey(celltext: string): string;
begin
  RESULT := PyCoder.extractJuPyCellKey(celltext);
end;

{ TPythonCodeAdapter }

constructor TPythonCodeAdapter.Create(lineBreak: string);
begin
  _RET_ := lineBreak;
end;

function TPythonCodeAdapter.excludeDelphiInteraction(
  pythoncode: string): string;
begin

end;

function TPythonCodeAdapter.extractJuPyCellKey(celltext: string): string;
begin
  RESULT := '';
  if not celltext.StartsWith(PYTHONLONGCOMMENT + CELLKEY) then
    exit;

  var line := extractTopLine(celltext);
  if not line.EndsWith(CELLKEY + PYTHONLONGCOMMENT) then
    exit;

  var Lcloses := Length(PYTHONLONGCOMMENT)+1;
  var LL := Length(line);

  RESULT := Trim( line.Substring(Lcloses, LL - 2 * Lcloses - 1) );
end;

function TPythonCodeAdapter.extractTopLine(text: string): string;
begin
  var posRET := StrUtils.PosEx(_RET_, text);
  if posRET > 0 then
    RESULT := text.Substring(0, posRET - 1)
  else
    RESULT := text;
end;

function TPythonCodeAdapter.includeDelphiInteraction(
  pythoncode: string): string;
begin
  setDelphiInteraction(pythoncode, true);   //wrap commenting
  setNativePyInteraction(pythoncode, false);   //unwrap commenting
  RESULT := pythoncode;
end;

function TPythonCodeAdapter.PYDELPHIONLYBEGIN: string;
begin
  RESULT := PYLONGMULTYDOCSTRING1 + '{' + _RET_
               + PYCOMMENT0BEGIN + _RET_ + '}'
               + PYLONGMULTYDOCSTRING1;
end;

function TPythonCodeAdapter.PYDELPHIONLYEND: string;
begin
  RESULT := PYLONGMULTYDOCSTRING1 + '{' + _RET_
               + PYCOMMENT0END + _RET_ + '}'
               + PYLONGMULTYDOCSTRING1;
end;

function TPythonCodeAdapter.PYNODELPHIBEGIN: string;
begin
  RESULT := PYLONGMULTYDOCSTRING0 + '{' + _RET_
             + PYCOMMENT1BEGIN + _RET_ + '}'
             + PYLONGMULTYDOCSTRING0;
end;

function TPythonCodeAdapter.PYNODELPHIEND: string;
begin
  RESULT := PYLONGMULTYDOCSTRING0 + '{' + _RET_
             + PYCOMMENT1END + _RET_ + '}'
             + PYLONGMULTYDOCSTRING0;
end;

//procedure TPythonCodeAdapter.rewrapping(var code: string; commentline,
//  comment2line: string; wrap: boolean);
//begin
//
//end;

procedure TPythonCodeAdapter.setDelphiInteraction(var pythoncode: string;
  active: boolean);
begin
  rewrapping(pythoncode, PYCOMMENT0BEGIN, PYDELPHIONLYBEGIN, active);
  rewrapping(pythoncode, PYCOMMENT0END, PYDELPHIONLYEND, active);
end;

procedure TPythonCodeAdapter.setNativePyInteraction(var pythoncode: string;
  active: boolean);
begin
  rewrapping(pythoncode, PYCOMMENT1BEGIN, PYNODELPHIBEGIN, active);
  rewrapping(pythoncode, PYCOMMENT1END, PYNODELPHIEND, active);
end;

procedure TPythonCodeAdapter.strip(var pythoncode: string; preWrap,
  postWrap: string);
begin
  if pythoncode.StartsWith(preWrap) and pythoncode.EndsWith(postWrap) then
  begin
    var LL := Length(pythoncode);
    var preL := Length(preWrap);
    var postL := Length(postWrap);

    pythoncode := pythoncode.Substring(preL, LL - (preL + postL));
  end;
end;

procedure TPythonCodeAdapter.wrap(var pythoncode: string; preWrap,
  postWrap: string);
begin
  pythoncode := preWrap + _RET_ + pythoncode + _RET_ + postWrap;
end;

function TPythonCodeAdapter.wrapAsJuPyOnly(pythoncode: string;
  stripping: boolean): string;
begin
  if stripping then
    strip(pythoncode, PYCOMMENT1BEGIN, PYCOMMENT1END)
  else
    wrap(pythoncode, PYCOMMENT1BEGIN, PYCOMMENT1END);
  RESULT := pythoncode;
end;

function TPythonCodeAdapter.wrapAsPyDelphiOnly(pythoncode: string;
  stripping: boolean): string;
begin
  if stripping then
    strip(pythoncode, PYDELPHIONLYBEGIN, PYDELPHIONLYEND)
  else
    wrap(pythoncode, PYDELPHIONLYBEGIN, PYDELPHIONLYEND);
  RESULT := pythoncode;
end;

begin
  PyCoder := TPythonCodeAdapter.Create(#$A);
end.
