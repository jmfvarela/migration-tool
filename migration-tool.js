const peg = require('pegjs');
const fs = require('fs');

function migrationTool(opts) {
    const basicGrammar = fs.readFileSync('grammars/basic-grammar.pegjs', 'utf8');
    const grammar = basicGrammar.replace('Rule = "##"', opts.pattern);
    const parser = peg.generate(grammar);
    const input = fs.readFileSync(opts.inputFile, 'utf8');
    const ast = parser.parse(input);
    return ast;
}

module.exports = migrationTool;