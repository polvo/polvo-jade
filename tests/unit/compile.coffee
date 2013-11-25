path = require 'path'
fs = require 'fs'
fsu = require 'fs-util'

should = require('chai').should()
jade = require '../../'

fixtures = path.join __dirname, '..', 'fixtures'

paths = 
  base: path.join fixtures, 'base.jade'
  _a: path.join fixtures, '_a.jade'
  _d: path.join fixtures, 'sub', '_d.jade'
  layout: path.join fixtures, '_layout', '_layout.jade'
  extends: path.join fixtures, '_layout', 'extends.jade'

contents = 
  base: fs.readFileSync(paths.base).toString()
  _d: fs.readFileSync(paths._d).toString()
  extends: fs.readFileSync(paths.extends).toString()

describe '[polvo-jade]', ->

  it 'should rise error and return empty string when jade returns an error', ->
    count =  err: 0, out: 0
    error =(msg)->
      count.err++
      /> 2| include _a/.test(msg).should.be.true
      /ENOENT.+'.+\/fixtures\/sub\/non\/existent.jade'/.test(msg).should.be.true
    done =( compiled )->
      count.out++
      compiled.should.equal ''

    jade.compile paths.base, contents.base, false, error, done
    count.out.should.equal 1
    count.err.should.equal 1

  it 'should compile file without any surprise - release mode', ->
    @timeout 5000
    count =  err: 0, out: 0
    error = (msg)-> count.err++
    done = ( compiled )->
      count.out++
      compiled.should.equal """module.exports = function anonymous(locals) {
      var buf = [];
      buf.push(\"<h1>A</h1><h1>A</h1><h1>B</h1><h1>C</h1><h1>D</h1>\");;return buf.join(\"\");
      }"""

    # remove inexistent include
    broken = fs.readFileSync(paths._a).toString()
    fixed = broken.replace 'include sub/non/existent', ''
    fs.writeFileSync paths._a, fixed

    jade.compile paths.base, contents.base, false, error, done
    count.out.should.equal 1
    count.err.should.equal 0

    # roll back original file
    fs.writeFileSync paths._a, broken

  it 'should compile file without any surprise - dev mode', ->
    @timeout 5000
    count =  err: 0, out: 0
    error = (msg)-> count.err++
    done = ( compiled )->
      count.out++
      compiled.match(/jade.+\.unshift\({ lineno: /g).length.should.be.above 15

    # remove inexistent include
    broken = fs.readFileSync(paths._a).toString()
    fixed = broken.replace 'include sub/non/existent', ''
    fs.writeFileSync paths._a, fixed

    jade.compile paths.base, contents.base, true, error, done
    count.out.should.equal 1
    count.err.should.equal 0

    # roll back original file
    fs.writeFileSync paths._a, broken

  it 'should return all file dependents, independently on how nested it is', ->
    list = []
    for file in fsu.find fixtures, /\.jade$/m
      list.push filepath:file, raw: fs.readFileSync(file).toString()

    dependents = jade.resolve_dependents paths._d, list
    dependents.length.should.equal 1
    dependents[0].filepath.should.equal paths.base

  it 'should fetch the helpers', ->
    filepath = path.join __dirname, '..', '..', 'node_modules', 'jade'
    filepath = path.join filepath, 'runtime.js'
    helper = fs.readFileSync filepath, 'utf-8'

    jade.fetch_helpers().should.be.equal helper

  it 'when the layout changes children must be updated', ->

    @timeout 5000
    count =  err: 0, out: 0
    compiled_content = original: '', modified: ''
    error = (msg)-> 

      console.error 'error ->', msg
      count.err++

    original_done = ( compiled )->
      count.out++
      compiled_content.original = compiled

    modified_done = ( compiled )->
      count.out++
      compiled_content.modified = compiled

    jade.compile paths.extends, contents.extends, false, error, original_done

    # modifies layout code
    original = fs.readFileSync(paths.layout).toString()
    modified = original.replace 'layer_3', 'layer_5'
    fs.writeFileSync paths.layout, modified

    jade.compile paths.extends, contents.extends, false, error, modified_done

    # roll back to original
    fs.writeFileSync paths.layout, original

    count.out.should.equal 2
    count.err.should.equal 0

    (compiled_content.original == compiled_content.modified).should.equal false

