{BufferedProcess} = require 'atom'
fs = require 'fs'

module.exports =
  activate: ->
    atom.workspaceView.command "swift-playground:execute", => @execute()

  execute: ->
    outputDir = "#{atom.getConfigDirPath()}/.swift-playground"
    fs.mkdir outputDir if not fs.existsSync outputDir
    inputFilePath = "#{outputDir}/input.swift"
    outputFilePath = "#{outputDir}/Swift Output"
    fs.writeFile inputFilePath, atom.workspace.getActiveEditor().getText()
    stdout = (output) =>
      fs.writeFile outputFilePath, output, (error)->
        throw error if error
        activePane = atom.workspace.getActivePane()
        atom.workspace.open(outputFilePath, {split: 'right', activatePane: no}).done (newEditor) -> activePane.activate()
    stderr = stdout
    new BufferedProcess {
      command: "xcrun",
      args: ["swift", inputFilePath],
      stdout,
      stderr
    }
