const peg = require('pegjs');
const fs = require('fs');

const grammar = fs.readFileSync("grammars/basic-grammar.pegjs", "utf8");
const parser = peg.generate(grammar);
const input = fs.readFileSync("data/input/JavaSonarRules.java", "utf8");
const ast = parser.parse(input);

const json = JSON.stringify(ast, null, 4);
fs.writeFileSync("data/output/JavaSonarRules.java.json", json);
console.log(json);
