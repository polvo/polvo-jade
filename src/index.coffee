(require 'source-map-support').install
  handleUncaughtExceptions: false

fs = require 'fs'
path = require 'path'
jade = require 'jade'
clone = require 'regexp-clone'

module.exports = new class Index

  # will be injected by polvo
  config: null

  type: 'template'
  name: 'jade'
  output: 'js'

  ext: /\.jade$/m
  exts: ['.jade' ]

  partials: on

  has_include = /^\s*(?:(?!\/\/).?)include\s/m
  match_all = /^\s*(?:(?!\/\/).?)include\s+(\S+)/mg

  is_partial:(filepath)->
    /^_/m.test path.basename filepath

  compile:( filepath, source, debug, error, done )->
    client = not @config.output.html?
    approach = if client then 'compile' else 'render'

    try
      compiled = jade[approach] source,
        filename: filepath
        client: client
        compileDebug: debug
        pretty: debug
    catch err
      error err
      return done '', null

    buffer = compiled
    buffer = 'module.exports = ' + buffer if client

    done buffer, null

  resolve_dependents:(filepath, files)->
    dependents = []

    for each in files
      [has, all] = [clone(has_include), clone(match_all)]
      continue if not has.test each.raw

      dirpath = path.dirname each.filepath
      name = path.basename each.filepath

      while (match = all.exec each.raw)?
        include = match[1]
        include = include.replace(@ext, '') + '.jade'
        include = path.join dirpath, include

        if include is filepath
          if not @is_partial name
            dependents.push each
          else
            sub = @resolve_dependents each.filepath, files
            dependents = dependents.concat sub

    dependents

  fetch_helpers:->
    filepath = path.join __dirname, '..', 'node_modules', 'jade'
    filepath = path.join filepath, 'runtime.js'
    fs.readFileSync filepath, 'utf-8'