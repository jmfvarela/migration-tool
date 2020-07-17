Start
  = head:Rule tail:(Rule)*

Rule
 = Comment
 / LineTerminatorSequence 
 / _
 / Literal
 / Identifier
 / Sign

Other
  = head:Char tail:(Char)* {
      return {
        type: "Text",
        text: buildList(head, tail, 0).join(''),
        };
    }

Sign
 = [=;"'+{.()}] // TODO

Char
  = !Rule char:(.) {return char;}

// Rule ----------------------------------------------------------------------------------------------

// Example: String sql = "select ... '" + expediente + "'";
Rule1
  = "String" __ id:Identifier __ "=" __ 
    {
      return {
        type: "Rule",
        id: id,
        parts: optionalList(extractOptional('parts', 0)),
        body: 'body'
      };
    }

Rule1Parts
  = head:Identifier tail:(__ "+" __ Identifier)* 
    {
      return buildList(head, tail, 3);
    }

// Basic grammar ------------------------------------------------------------------------------------------

__
  = (WhiteSpace / LineTerminatorSequence / Comment)*

_
  = first:WhiteSpace rest:WhiteSpace* {
      return {
        type: "WhiteSpace",
        text: first + rest.join(''),
        };
    }

WhiteSpace "whitespace"
  = [ \t\v\f\u00A0\uFEFF\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000] 

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029" { 
    return {
      type: 'LineTerminatorSequence',
      };
    }

Comment "comment"
  = MultiLineComment
  / SingleLineComment

MultiLineComment
  = first:"/*" med:(!"*/" .)* last:"*/" { 
      return {
        type: 'MultiLineComment',
        text: first.concat(med.map(a => a[1]).join('')).concat(last),
        };
    }

SingleLineComment
  = first:"//" last:(![\n\r\u2028\u2029] .)* {
    return {
      type: 'SingleLineComment',
      text: first.concat(last.map(a => a[1]).join('')),
      }
    }

Identifier "identifier"
  = !Keyword first:Letter rest:LetterOrDigit* {
      return {
        type: "Identifier",
        text: first + rest.join(''),
        };
    }

LetterOrDigit 
  = Letter / Digit

Letter 
  = [a-z] / [A-Z] / [_$]

Digit 
  = [0-9]

Keyword
    = ( "abstract"
      / "while"
      ) !LetterOrDigit

Literal "literal"
    = FloatLiteral
    / IntegerLiteral          // May be a prefix of FloatLiteral
    / BooleanLiteral
    //StringLiteral

IntegerLiteral
    = HexNumeral
    / BinaryNumeral
    / OctalNumeral            // May be a prefix of HexNumeral or BinaryNumeral
    / DecimalNumeral          // May be a prefix of OctalNumeral

DecimalNumeral
    = "0"
    / [1-9]([_]*[0-9])*

HexadecimalFloatingPointLiteral
    = HexSignificand BinaryExponent [fFdD]? ;

HexSignificand
    = ("0x" / "0X") HexDigits? "." HexDigits
    / HexNumeral "."?                           // May be a prefix of above
    ;

HexNumeral
    = ("0x" / "0X") HexDigits

HexDigits
    = HexDigit ([_]*HexDigit)* ;

HexDigit
    = [a-f] / [A-F] / [0-9] ;

OctalNumeral
    = "0" ([_]*[0-7])+

BinaryNumeral
    = ("0b" / "0B") [01]([_]*[01])*

FloatLiteral
    = HexadecimalFloatingPointLiteral
    / DecimalFloatingPointLiteral   // May be a prefix of above

DecimalFloatingPointLiteral
    = Digits "." Digits?  Exponent? [fFdD]?
    / "." Digits Exponent? [fFdD]?
    / Digits Exponent [fFdD]?
    / Digits Exponent? [fFdD]

Exponent
    = [eE] [+\-]? Digits

BinaryExponent
    = [pP] [+\-]? Digits ;

Digits
    = [0-9]([_]*[0-9])*

BooleanLiteral
    = "true"
    / "false"

QualIdent
    = Identifier ("." Identifier)*

