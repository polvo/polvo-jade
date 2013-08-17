(require 'source-map-support').install
  handleUncaughtExceptions: false

fs = require 'fs'
path = require 'path'
jade = require 'jade'

module.exports = new class Index

  polvo: true

  type: 'template'
  name: 'jade'
  output: 'js'

  ext: /\.jade$/m
  exts: ['.jade' ]

  partials: on
  is_partial:(filepath)-> /^_/m.test path.basename filepath

  compile:( filepath, source, debug, error, done )->
    try
      compiled = jade.compile source,
        filename: filepath
        client: true
        compileDebug: debug
    catch err
      return error err

    done 'module.exports = ' + compiled, null

  resolve_dependents:(file, files)->
    dependents = []
    has_include_calls = /^\s*(?!\/\/)include\s/m

    for each in files

      continue if not has_include_calls.test each.raw

      dirpath = path.dirname each.filepath
      name = path.basename each.filepath
      match_all = /^\s*(?!\/\/)include\s+(\S+)/mg

      while (match = match_all.exec each.raw)?

        short_id = match[1]
        short_id += '.jade' if '' is path.extname short_id

        full_id = path.join dirpath, short_id

        if full_id is file.filepath
          if not @is_partial name
            dependents.push each
          else
            dependents = dependents.concat @resolve_dependents each, files

    dependents