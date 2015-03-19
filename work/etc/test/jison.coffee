
parser = new require("jison").Parser grammar=
    "lex":
        "rules":[
            ["\\s+",      "/* skip whitespace */"]
            ["[a-f0-9]+", "return 'HEX';"]
        ]
    "bnf": 
        "hex_strings":[ "hex_strings HEX", "HEX" ]

console.log parser.parse "adfe34bc e82a"