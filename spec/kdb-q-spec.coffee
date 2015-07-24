describe 'Q grammar tests', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-kdb-q')
    runs ->
      grammar = atom.grammars.grammarForScopeName('source.q')

  it 'checks the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.q'

  it 'checks control token', ->
    {tokens} = grammar.tokenizeLine 'do[10;20]'

    expect(tokens.length).toEqual 6

    expect(tokens[0]).toEqual
      value: 'do'
      scopes: [
        'source.q'
        'keyword.control.q'
      ]

    expect(tokens[1]).toEqual
      value: '['
      scopes: [
        'source.q'
        'meta.brace.open.q'
      ]

    expect(tokens[2]).toEqual
      value: '10'
      scopes: [
        'source.q'
        'constant.numeric.q'
      ]

    expect(tokens[3]).toEqual
      value: ';'
      scopes: [
        'source.q'
        'meta.punctuation.q'
      ]

    expect(tokens[4]).toEqual
      value: '20'
      scopes: [
        'source.q'
        'constant.numeric.q'
      ]

    expect(tokens[5]).toEqual
      value: ']'
      scopes: [
        'source.q'
        'meta.brace.close.q'
      ]

  it 'checks operator token', ->
    {tokens} = grammar.tokenizeLine 'a , b lj x'

    expect(tokens.length).toEqual 9

    expect(tokens[0]).toEqual
      value: 'a'
      scopes: [
        'source.q'
        'entity.name.q'
      ]

    expect(tokens[1]).toEqual
      value: ' '
      scopes: [
        'source.q'
      ]

    expect(tokens[2]).toEqual
      value: ','
      scopes: [
        'source.q'
        'keyword.operator.q'
      ]

    expect(tokens[8]).toEqual
      value: 'x'
      scopes: [
        'source.q'
        'variable.language.q'
      ]

  it 'checks block comment', ->
    lines = grammar.tokenizeLines '/  \n    some comment\n\\  '

    expect(lines.length).toEqual 3

    for l in lines
      expect(l.length).toEqual 1
      expect(l[0].scopes).toEqual ['source.q', 'comment.block.simple.q']

  it 'checks line comment', ->
    {tokens} = grammar.tokenizeLine '/ some comment'

    expect(tokens.length).toEqual 1

    expect(tokens[0].scopes).toEqual ['source.q','comment.line.q']

    {tokens} = grammar.tokenizeLine 'txt / another comment'

    expect(tokens.length).toEqual 2

    expect(tokens[1].scopes).toEqual ['source.q','comment.line.q']

    {tokens} = grammar.tokenizeLine 'do not comment this/[arg]'

    expect(tokens.length).toEqual 11

    expect(tokens[9]).toEqual
      value: 'arg'
      scopes: [
        'source.q'
        'entity.name.q'
      ]

  it 'checks eof block comment', ->
    lines = grammar.tokenizeLines '\\  \n  /\n  some comment\n\\ \n aaa'

    expect(lines.length).toEqual 5

    for l in lines
      expect(l.length).toEqual 1
      expect(l[0].scopes).toEqual ['source.q', 'comment.block.eof.q']

  it 'checks Q cmd line', ->
    {tokens} = grammar.tokenizeLine '\\some cmd'

    expect(tokens.length).toEqual 1

    expect(tokens[0]).toEqual
      value: '\\some cmd'
      scopes: [
        'source.q'
        'constant.other.q'
      ]

  it 'checks string token', ->
    {tokens} = grammar.tokenizeLine '"str" "aaa\\nb\\tc\\""'

    expect(tokens.length).toEqual 12

    expect(tokens[0]).toEqual
      value: '"'
      scopes: [
        'source.q'
        'string.quoted.single.q'
      ]

    expect(tokens[5]).toEqual
      value: 'aaa'
      scopes: [
        'source.q'
        'string.quoted.single.q'
      ]

    expect(tokens[6]).toEqual
      value: '\\n'
      scopes: [
        'source.q'
        'string.quoted.single.q'
        'constant.character.escape.q'
      ]

  it 'checks functions', ->
    {tokens} = grammar.tokenizeLine 'first 0nh 0xAf12'

    expect(tokens.length).toEqual 5

    expect(tokens[0]).toEqual
      value: 'first'
      scopes: [
        'source.q'
        'support.function.q'
      ]

    expect(tokens[2]).toEqual
      value: '0nh'
      scopes: [
        'source.q'
        'constant.language.q'
      ]

    expect(tokens[4]).toEqual
      value: '0xAf12'
      scopes: [
        'source.q'
        'constant.numeric.q'
      ]

  it 'checks timestamp/span tokens', ->
    {tokens} = grammar.tokenizeLine '10D 10D10 10D10:10 10D10:10:10 10D10:10:10.11 10Dz 10D10p 10D10:10n 10D10:10:10z 10D10:10:10.11p \
      2001.10.10D 2001.10.10D10 2001.10.10D10:10 2001.10.10D10:10:10 2001.10.10D10:10:10.11 \
      2001.10.10Dz 10D10p 2001.10.10D10:10n 2001.10.10D10:10:10z 2001.10.10D10:10:10.11p'

    expect(tokens.length).toEqual 39

    for t in tokens by 2
      expect(t.scopes).toEqual  ['source.q','constant.numeric.q']
