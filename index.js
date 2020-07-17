const migrationTool = require('./migration-tool');

const ast = migrationTool({
    inputFile: "data/input/JavaSonarRules.java",
    pattern: `
        // Example pattern: String sql = "select ... '" + expediente + "'";
        Rule
          = "String" __ id:Identifier __ "=" __ ruleparts:RuleParts ";"
            { return {type:"Rule1", id:id.value, ruleparts:ruleparts}; }

        RuleParts
        = head:RulePart tail:(__ "+" __ RulePart)* 
          { return {type:"RuleParts", value:[head].concat(tail.map(a => a[3]))}; }

        RulePart
        = Identifier / StringLiteral
    `});

const json = JSON.stringify(ast, null, 4);
console.log(json);


