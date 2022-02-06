unit UnitPy4DUtils;

interface

type
  TPythonCodeAdapter = Class
  End;

  function includeDelphiInteraction(pythoncode: string): string;
  function excludeDelphiInteraction(pythoncode: string): string;
  procedure commenting(var code: string; commentline, comment2line: string; uncomment: boolean);
implementation
uses SysUtils;
const
  PYLONGMULTYDOCSTRING0 = '"""';
  PYLONGMULTYDOCSTRING1 = '''''''';

  PYCOMMENT0BEGIN = PYLONGMULTYDOCSTRING0 + '!';
  PYCOMMENT0END =   '!' + PYLONGMULTYDOCSTRING0;

  PYCOMMENT1BEGIN = PYLONGMULTYDOCSTRING1 + '$';
  PYCOMMENT1END =   '$' + PYLONGMULTYDOCSTRING1;



  PYDELPHIONLYBEGIN = PYLONGMULTYDOCSTRING1 + '{' + #$D#$A
               + PYLONGMULTYDOCSTRING0 + '!' + #$D#$A + '}'
               + PYLONGMULTYDOCSTRING1;
  PYDELPHIONLYEND = PYLONGMULTYDOCSTRING1 + '{' + #$D#$A
               + '!' + PYLONGMULTYDOCSTRING0 + #$D#$A + '}'
               + PYLONGMULTYDOCSTRING1;
  PYNODELPHIBEGIN = PYLONGMULTYDOCSTRING0 + '{' + #$D#$A
             + PYLONGMULTYDOCSTRING1 + '$' + #$D#$A + '}'
             + PYLONGMULTYDOCSTRING0;

  PYNODELPHIEND = PYLONGMULTYDOCSTRING0 + '{' + #$D#$A
             + '$' +  PYLONGMULTYDOCSTRING1 + #$D#$A + '}'
             + PYLONGMULTYDOCSTRING0;


function includeDelphiInteraction(pythoncode: string): string;
begin
  //uncomment comments """! ... !""" without  '''{ ... }'''
  commenting(pythoncode, PYCOMMENT1BEGIN, PYNODELPHIBEGIN, true);
  commenting(pythoncode, PYCOMMENT1END, PYNODELPHIEND, true);
  //comment '''$ ... $''' comments  with """{ ... }"""
  commenting(pythoncode, PYCOMMENT0BEGIN, PYNODELPHIBEGIN, false);
  commenting(pythoncode, PYCOMMENT0END, PYNODELPHIEND, false);
  RESULT := pythoncode;
end;
function excludeDelphiInteraction(pythoncode: string): string;
begin
  //uncomment '''$ ... $''' comments  without """{ ... }"""
  commenting(pythoncode, PYCOMMENT0BEGIN, PYDELPHIONLYBEGIN, true);
  commenting(pythoncode, PYCOMMENT0END, PYDELPHIONLYEND, true);
  //comment comments """! ... !""" with  '''{ ... }'''
  commenting(pythoncode, PYCOMMENT1BEGIN, PYNODELPHIBEGIN, false);
  commenting(pythoncode, PYCOMMENT1END, PYNODELPHIEND, false);
  RESULT := pythoncode;
end;
procedure commenting(var code: string; commentline, comment2line: string; uncomment: boolean);
var orig, target: string;
begin
  if uncomment then
  begin
    orig := comment2line;
    target := commentline;
  end
  else
  begin
    orig := commentline;
    target := comment2line;
  end;

  code := StringReplace(code, orig, target, [rfReplaceAll]);
end;
end.
