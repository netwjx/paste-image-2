{dirname, join} = require 'path'
dateformat = require 'dateformat'
fs = require 'fs'
{Point} = require 'text-buffer'

module.exports =
  activate: (state)->
    attachEvent()
    console.debug('activate')

attachEvent = ->
  workspaceEle = atom.views.getView atom.workspace
  workspaceEle.addEventListener 'keydown', (e)->
    if e.metaKey and e.keyCode is 86 and not (e.altKey or e.ctrlKey or e.shiftKey)
      clipboard = require 'clipboard'
      img = clipboard.readImage()
      return if img.isEmpty()

      editor = atom.workspace.getActiveTextEditor()
      grammar = editor.getGrammar()
      if /(markdown|html)/i.test grammar.name
        name = RegExp.$1.toLowerCase()
        imgName = "paste-image-#{dateformat new Date(), 'yyyy-mm-dd-HH-MM-ss'}-#{Math.random() * 1000 | 0}.png"
        fs.writeFile join(dirname(editor.getPath()), imgName), img.toPng(), ->
          console.info 'Ok! Image is saved'
        
        switch name
          when 'markdown'
            debugger
            [range] = editor.insertText "![#{imgName}](#{imgName})"
            range = range.translate new Point(0,2), new Point(0, -(imgName.length + 3))
          when 'html'
            [range] = editor.insertText "<img src=\"#{imgName}\" alt=\"#{imgName}\" />"
            range = range.translate new Point(0, imgName.length + 17), new Point(0, -4)
            
        requestAnimationFrame ->
          editor.setSelectedBufferRange(range)
