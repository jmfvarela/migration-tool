Start = BasicGrammar

// Insert your rule here ----------------------------------------------------------------------------------

Rule = "##"

// Basic grammar ------------------------------------------------------------------------------------------

BasicGrammar
  = head:Element tail:(Element)*

Element
 = Rule
 / _
 / Comment
 / Literal
 / Identifier
 / Sign

Sign
 = value:[=;"'+{.()}] { // TODO
     return {
       type: "Sign",
       value: value,
     };
   }

__
  = (WhiteSpace / Comment)*

_
  = first:WhiteSpace rest:WhiteSpace* {
      return {
        type: "WhiteSpace",
        value: first + rest.join(''),
        };
    }

WhiteSpace "whitespace"
  = [ \r\n\t\v\f\u00A0\uFEFF\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000] 

Comment "comment"
  = MultiLineComment
  / SingleLineComment

MultiLineComment
  = first:"/*" med:(!"*/" .)* last:"*/" { 
      return {
        type: 'MultiLineComment',
        value: first.concat(med.map(a => a[1]).join('')).concat(last),
        };
    }

SingleLineComment
  = first:"//" last:(![\n\r\u2028\u2029] .)* {
    return {
      type: 'SingleLineComment',
      value: first.concat(last.map(a => a[1]).join('')),
      }
    }

Identifier "identifier"
  = !Keyword first:Letter rest:LetterOrDigit* {
      return {
        type: "Identifier",
        value: first + rest.join(''),
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
    / StringLiteral

IntegerLiteral
    = HexNumeral
    / BinaryNumeral
    / OctalNumeral            // May be a prefix of HexNumeral or BinaryNumeral
    / DecimalNumeral          // May be a prefix of OctalNumeral

DecimalNumeral
    = "0"
    / [1-9]([_]*[0-9])*

HexadecimalFloatingPointLiteral
    = HexSignificand BinaryExponent [fFdD]?

HexSignificand
    = ("0x" / "0X") HexDigits? "." HexDigits
    / HexNumeral "."?                           // May be a prefix of above

HexNumeral
    = ("0x" / "0X") HexDigits

HexDigits
    = HexDigit ([_]*HexDigit)*

HexDigit
    = [a-f] / [A-F] / [0-9]

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



// StringLiteral -------------------------------------------------

StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return { type: "Literal", subtype: "String", value: chars.join("") };
    }
  / "'" chars:SingleStringCharacter* "'" {
      return { type: "Literal", subtype: "String", value: chars.join("") };
    }

DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) . { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

LineTerminator
  = [\n\r\u2028\u2029]

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"

SingleStringCharacter
  = !("'" / "\\" / LineTerminator) . { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

LineContinuation
  = "\\" LineTerminatorSequence { return ""; }

EscapeSequence
  = CharacterEscapeSequence
  / "0" ![0-9] { return "\0"; }
  / HexEscapeSequence
  / UnicodeEscapeSequence

CharacterEscapeSequence
  = SingleEscapeCharacter
  / NonEscapeCharacter

SingleEscapeCharacter
  = "'"
  / '"'
  / "\\"
  / "b"  { return "\b"; }
  / "f"  { return "\f"; }
  / "n"  { return "\n"; }
  / "r"  { return "\r"; }
  / "t"  { return "\t"; }
  / "v"  { return "\v"; }

NonEscapeCharacter
  = !(EscapeCharacter / LineTerminator) . { return text(); }

EscapeCharacter
  = SingleEscapeCharacter
  / [0-9]
  / "x"
  / "u"

HexEscapeSequence
  = "x" digits:$(HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

UnicodeEscapeSequence
  = "u" digits:$(HexDigit HexDigit HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }
