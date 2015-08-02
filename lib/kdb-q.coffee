{CompositeDisposable, Point} = require 'atom'
_ = require 'underscore-plus'

module.exports = KdbQ =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.observeTextEditors (editor) ->
      return unless editor.getGrammar().scopeName == "source.q"
      _.defer ->
        _.adviseBefore editor, 'insertText', (text,opt) -> # hack required to supress bracket-matcher undesired behaviour
          return true unless text
          return true if opt?.select or opt?.undo is 'skip'
          return true if editor.hasMultipleCursors()
          if text is "'" or text is "`"
            editor.insertText text + ' ', opt
            editor.backspace()
            false
          else
            true
      _.defer ->
        _.adviseBefore editor, 'insertNewline', ->
          return true if editor.hasMultipleCursors()
          return true unless editor.getLastSelection().isEmpty()
          # TODO? return true if editor.isBufferRowCommented ....
          cursorBufferPosition = editor.getCursorBufferPosition()
          row = cursorBufferPosition.row
          previousCharacters = editor.getTextInBufferRange([new Point(row,0), cursorBufferPosition])
          nextCharacter = editor.getTextInBufferRange([cursorBufferPosition, cursorBufferPosition.traverse([0, 1])])
          {tokens} = editor.getGrammar().tokenizeLine previousCharacters
          br = 0; pr = 0; sq = 0
          for t in tokens
            switch t.value
              when '{' then br++
              when '[' then sq++
              when '(' then pr++
              when '}' then br--
              when ']' then sq--
              when ')' then pr--
          return true if br <= 0 and pr <= 0 and sq <= 0
          # some bracket is not closed
          editor.transact =>
            lvl = editor.indentationForBufferRow row
            two = ('}])'.includes nextCharacter) and nextCharacter.length>0
            editor.insertText (if two then "\n\n" else "\n") + if lvl>0 then '' else ' '
            editor.moveUp() if two
            if atom.config.get 'editor.autoIndent'
              editor.setIndentationForBufferRow row+1,lvl+1
              editor.setIndentationForBufferRow row+2,lvl if lvl>0 and two
          false

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
