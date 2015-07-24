describe "Autocomplete tests", ->
  editor = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage "bracket-matcher"

    waitsForPromise ->
      jasmine.unspy(window, 'setTimeout') # TODO: how to avoid this?
      atom.packages.activatePackage "language-kdb-q"

    waitsForPromise ->
      atom.workspace.open("foofoo.q").then (o) ->
        editor = o

  it 'expects one backtick and single quote but double double quotes', ->
    spy = jasmine.createSpy 'wait' # need to wait 1 cycle
    setTimeout (v) ->
        spy 1
      ,0
    waitsFor ->
      spy.callCount > 0
    runs ->
      editor.insertText '"'
      editor.insertText "'"
      editor.insertText '`'
      expect(editor.getText()).toEqual '"\'`"'
