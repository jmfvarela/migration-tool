const peg = require('pegjs');
const fs = require('fs');

const grammar = fs.readFileSync("grammars/grammar.pegjs", "utf8");
const parser = peg.generate(grammar);
const src = fs.readFileSync("src/FizzBuzz.js", "utf8");
const ast = parser.parse(src);

const json = JSON.stringify(ast, null, 4);
fs.writeFileSync("dest/FizzBuzz.json", json);

const dest = migrate(ast);
fs.writeFileSync("dest/FizzBuzz.js", dest);
console.log(dest);

// Recursive function with a global counter
// https://stackoverflow.com/questions/37911429/recursive-function-maintain-a-global-counter-without-using-a-global-variable
function migrate(ast) {
    let level = 0;
    return m(ast);

    function m(o) {
        if (o.type == "Program") {
            return mList(o.body, "\n");
        }
        else if (o.type == "ForStatement") {
            return `for (${m(o.init)}; ${m(o.test)}; ${m(o.update)}) {\n${indent(++level)}${m(o.body)}${indent(--level)}}`;
        }
        else if (o.type == "VariableDeclaration") {
            return o.kind + " " + mList(o.declarations, ", ");
        }
        else if (o.type == "VariableDeclarator") {
            return `${m(o.id)} = ${m(o.init)}`;
        }
        else if (o.type == "Identifier") {
            return `${o.name}`;
        }
        else if (o.type == "Literal") {
            if (typeof o.value === 'string') return `"${o.value}"`;
            else return `${o.value}`;
        }
        else if (o.type == "BinaryExpression") {
            return `${m(o.left)} ${o.operator} ${m(o.right)}`;
        }
        else if (o.type == "UpdateExpression") {
            if (o.prefix) {
                return `${m(o.argument)}${o.operator}`;
            }
            else {
                return `${m(o.argument)}${o.operator}`;
            }
        }
        else if (o.type == "BlockStatement") {
            return mList(o.body, "\n");
        }
        else if (o.type == "IfStatement") {
            if (o.alternate.type == "IfStatement") {
                return `if (${m(o.test)}) {\n${indent(++level)}${m(o.consequent)}${indent(--level)}} else ${m(o.alternate)}`;
            }
            else {
                return `if (${m(o.test)}) {\n${indent(++level)}${m(o.consequent)}${indent(--level)}} else {\n${indent(++level)}${m(o.alternate)}${indent(--level)}}\n`;
            }
        }
        else if (o.type == "LogicalExpression") {
            return `${m(o.left)} ${o.operator} ${m(o.right)}`;
        }
        else if (o.type == "ExpressionStatement") {
            return `${m(o.expression)};\n`;
        }
        else if (o.type == "CallExpression") {
            return `${m(o.callee)}(${mList(o.arguments, ", ")})`;
        }
        else if (o.type == "MemberExpression") {
            if (o.computed) {
                return `${m(o.object)}[${m(o.property)}]`;
            }
            else {
                return `${m(o.object)}.${m(o.property)}`;
            }
        }
        else {
            return todo(o);
        }
    }

    function indent(level) {
        return "    ".repeat(level);
    }

    function mList(list, sep) {
        return list.map(m).join(sep);
    }

    function todo(o) {
        if (o instanceof Object) {
            return "/* TODO: " + Object.keys(o).map(key => key + ": " + o[key]).join(", ") + " */";
        }
        else return "/* TODO: " + o + " */";
    }
}
