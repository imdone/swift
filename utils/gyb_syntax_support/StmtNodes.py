from Child import Child
from Node import Node  # noqa: I201

STMT_NODES = [
    # continue-stmt -> 'continue' label? ';'?
    Node('ContinueStmt', kind='Stmt',
         children=[
             Child('ContinueKeyword', kind='ContinueToken'),
             Child('Label', kind='IdentifierToken',
                   is_optional=True),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # while-stmt -> label? ':'? 'while' condition-list code-block ';'?
    Node('WhileStmt', kind='Stmt',
         children=[
             Child('LabelName', kind='IdentifierToken',
                   is_optional=True),
             Child('LabelColon', kind='ColonToken',
                   is_optional=True),
             Child('WhileKeyword', kind='WhileToken'),
             Child('Conditions', kind='ConditionElementList'),
             Child('Body', kind='CodeBlock'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # defer-stmt -> 'defer' code-block ';'?
    Node('DeferStmt', kind='Stmt',
         children=[
             Child('DeferKeyword', kind='DeferToken'),
             Child('Body', kind='CodeBlock'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # expr-stmt -> expression ';'?
    Node('ExpressionStmt', kind='Stmt',
         children=[
             Child('Expression', kind='Expr'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # switch-case-list -> switch-case switch-case-list?
    Node('SwitchCaseList', kind='SyntaxCollection',
         element='SwitchCase'),

    # repeat-while-stmt -> label? ':'? 'repeat' code-block 'while' expr ';'?
    Node('RepeatWhileStmt', kind='Stmt',
         children=[
             Child('LabelName', kind='IdentifierToken',
                   is_optional=True),
             Child('LabelColon', kind='ColonToken',
                   is_optional=True),
             Child('RepeatKeyword', kind='RepeatToken'),
             Child('Body', kind='CodeBlock'),
             Child('WhileKeyword', kind='WhileToken'),
             Child('Condition', kind='Expr'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # guard-stmt -> 'guard' condition-list 'else' code-block ';'?
    Node('GuardStmt', kind='Stmt',
         children=[
             Child('GuardKeyword', kind='GuardToken'),
             Child('Conditions', kind='ConditionElementList'),
             Child('ElseKeyword', kind='ElseToken'),
             Child('Body', kind='CodeBlock'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    Node('WhereClause', kind='Syntax',
         children=[
             Child('WhereKeyword', kind='WhereToken'),
             Child('GuardResult', kind='Expr'),
         ]),

    # for-in-stmt -> label? ':'? 'for' 'case'? pattern 'in' expr 'where'?
    #   expr code-block ';'?
    Node('ForInStmt', kind='Stmt',
         children=[
             Child('LabelName', kind='IdentifierToken',
                   is_optional=True),
             Child('LabelColon', kind='ColonToken',
                   is_optional=True),
             Child('ForKeyword', kind='ForToken'),
             Child('CaseKeyword', kind='CaseToken',
                   is_optional=True),
             Child('Pattern', kind='Pattern'),
             Child('TypeAnnotation', kind='TypeAnnotation',
                   is_optional=True),
             Child('InKeyword', kind='InToken'),
             Child('SequenceExpr', kind='Expr'),
             Child('WhereClause', kind='WhereClause',
                   is_optional=True),
             Child('Body', kind='CodeBlock'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # switch-stmt -> identifier? ':'? 'switch' expr '{'
    #   switch-case-list '}' ';'?
    Node('SwitchStmt', kind='Stmt',
         children=[
             Child('LabelName', kind='IdentifierToken',
                   is_optional=True),
             Child('LabelColon', kind='ColonToken',
                   is_optional=True),
             Child('SwitchKeyword', kind='SwitchToken'),
             Child('Expression', kind='Expr'),
             Child('OpenBrace', kind='LeftBraceToken'),
             Child('Cases', kind='SwitchCaseList'),
             Child('CloseBrace', kind='RightBraceToken'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # catch-clause-list -> catch-clause catch-clause-list?
    Node('CatchClauseList', kind='SyntaxCollection',
         element='CatchClause'),

    # do-stmt -> identifier? ':'? 'do' code-block catch-clause-list ';'?
    Node('DoStmt', kind='Stmt',
         children=[
             Child('LabelName', kind='IdentifierToken',
                   is_optional=True),
             Child('LabelColon', kind='ColonToken',
                   is_optional=True),
             Child('DoKeyword', kind='DoToken'),
             Child('Body', kind='CodeBlock'),
             Child('CatchClauses', kind='CatchClauseList',
                   is_optional=True),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # return-stmt -> 'return' expr? ';'?
    Node('ReturnStmt', kind='Stmt',
         children=[
             Child('ReturnKeyword', kind='ReturnToken'),
             Child('Expression', kind='Expr',
                   is_optional=True),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # fallthrough-stmt -> 'fallthrough' ';'?
    Node('FallthroughStmt', kind='Stmt',
         children=[
             Child('FallthroughKeyword', kind='FallthroughToken'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # break-stmt -> 'break' identifier? ';'?
    Node('BreakStmt', kind='Stmt',
         children=[
             Child('BreakKeyword', kind='BreakToken'),
             Child('Label', kind='IdentifierToken',
                   is_optional=True),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # code-block -> '{' stmt-list '}'
    Node('CodeBlock', kind='Syntax',
         children=[
             Child('OpenBrace', kind='LeftBraceToken'),
             Child('Statements', kind='StmtList'),
             Child('CloseBrace', kind='RightBraceToken'),
         ]),

    # case-item-list -> case-item case-item-list?
    Node('CaseItemList', kind='SyntaxCollection',
         element='CaseItem'),

    # condition -> expression
    #            | availability-condition
    #            | case-condition
    #            | optional-binding-condition
    Node('ConditionElement', kind='Syntax',
         children=[
             Child('Condition', kind='Syntax',
                   node_choices=[
                       Child('Expression', kind='Expr'),
                       Child('Availablity', kind='AvailabilityCondition'),
                       Child('MatchingPattern',
                             kind='MatchingPatternCondition'),
                       Child('OptionalBinding',
                             kind='OptionalBindingCondition'),
                   ]),
             Child('TrailingComma', kind='CommaToken',
                   is_optional=True),
         ]),
    Node('AvailabilityCondition', kind='Syntax',
         children=[
             Child('PoundAvailableKeyword', kind='PoundAvailableToken'),
             Child('Arguments', kind='TokenList'),
         ]),
    Node('MatchingPatternCondition', kind='Syntax',
         children=[
             Child('CaseKeyword', kind='CaseToken'),
             Child('Pattern', kind='Pattern'),
             Child('TypeAnnotation', kind='TypeAnnotation',
                   is_optional=True),
             Child('Initializer', kind='InitializerClause'),
         ]),
    Node('OptionalBindingCondition', kind='Syntax',
         children=[
             Child('LetOrVarKeyword', kind='Token',
                   token_choices=[
                       'LetToken', 'VarToken',
                   ]),
             Child('Pattern', kind='Pattern'),
             Child('TypeAnnotation', kind='TypeAnnotation',
                   is_optional=True),
             Child('Initializer', kind='InitializerClause'),
         ]),

    # condition-list -> condition
    #                 | condition ','? condition-list
    Node('ConditionElementList', kind='SyntaxCollection',
         element='ConditionElement'),

    # A declaration in statement position.
    # struct Foo {};
    Node('DeclarationStmt', kind='Stmt',
         children=[
             Child('Declaration', kind='Decl'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # throw-stmt -> 'throw' expr ';'?
    Node('ThrowStmt', kind='Stmt',
         children=[
             Child('ThrowKeyword', kind='ThrowToken'),
             Child('Expression', kind='Expr'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # if-stmt -> identifier? ':'? 'if' condition-list code-block
    #   else-clause ';'?
    Node('IfStmt', kind='Stmt',
         children=[
             Child('LabelName', kind='IdentifierToken',
                   is_optional=True),
             Child('LabelColon', kind='ColonToken',
                   is_optional=True),
             Child('IfKeyword', kind='IfToken'),
             Child('Conditions', kind='ConditionElementList'),
             Child('Body', kind='CodeBlock'),
             Child('ElseKeyword', kind='ElseToken',
                   is_optional=True),
             Child('ElseBody', kind='Syntax',
                   node_choices=[
                       Child('IfStmt', kind='IfStmt'),
                       Child('CodeBlock', kind='CodeBlock'),
                   ],
                   is_optional=True),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # else-if-continuation -> label? ':'? 'while' condition-list code-block ';'
    Node('ElseIfContinuation', kind='Syntax',
         children=[
             Child('IfStatement', kind='IfStmt'),
         ]),

    # else-clause -> 'else' code-block
    Node('ElseBlock', kind='Syntax',
         children=[
             Child('ElseKeyword', kind='ElseToken'),
             Child('Body', kind='CodeBlock'),
             Child('Semicolon', kind='SemicolonToken',
                   is_optional=True),
         ]),

    # stmt-list -> stmt stmt-list?
    Node('StmtList', kind='SyntaxCollection',
         element='Stmt'),

    # switch-case -> switch-case-label stmt-list
    #              | default-label stmt-list
    Node('SwitchCase', kind='Syntax',
         children=[
             Child('Label', kind='Syntax'),
             Child('Body', kind='StmtList'),
         ]),

    # switch-default-label -> 'default' ':'
    Node('SwitchDefaultLabel', kind='Syntax',
         children=[
             Child('DefaultKeyword', kind='DefaultToken'),
             Child('Colon', kind='ColonToken'),
         ]),

    # case-item -> pattern where-clause? ','?
    Node('CaseItem', kind='Syntax',
         children=[
             Child('Pattern', kind='Pattern'),
             Child('WhereClause', kind='WhereClause',
                   is_optional=True),
             Child('Comma', kind='CommaToken',
                   is_optional=True),
         ]),

    # switch-case-label -> 'case' case-item-list ':'
    Node('SwitchCaseLabel', kind='Syntax',
         children=[
             Child('CaseKeyword', kind='CaseToken'),
             Child('CaseItems', kind='CaseItemList'),
             Child('Colon', kind='ColonToken'),
         ]),

    # catch-clause 'catch' pattern? where-clause? code-block
    Node('CatchClause', kind='Syntax',
         children=[
             Child('CatchKeyword', kind='CatchToken'),
             Child('Pattern', kind='Pattern',
                   is_optional=True),
             Child('WhereClause', kind='WhereClause',
                   is_optional=True),
             Child('Body', kind='CodeBlock'),
         ]),
]
