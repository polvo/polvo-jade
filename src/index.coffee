(require 'source-map-support').install
  handleUncaughtExceptions: false

fs = require 'fs'
path = require 'path'
jade = require 'jade'

module.exports = new class Index

  polvo: true

  type: 'js'
  name: 'jade'
  ext: /\.jade$/m
  exts: ['.jade' ]

  compile:( filepath, source, debug, done )->
    try
      compiled = jade.compile source,
        filename: filepath
        client: true
        compileDebug: debug
    catch err
      throw err

    done 'module.exports = ' + compiled, null

  fetch_helpers:->
    filepath = path.join __dirname, 'node_modules', 'jade', 'runtime.js'
    fs.readFileSync filepath, 'utf-8'