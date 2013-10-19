# Polvo Jade

With this plugin, Polvo can handle Jade source files.

[![Stories in Ready](https://badge.waffle.io/polvo/polvo-jade.png)](https://waffle.io/polvo/polvo-jade)

[![Build Status](https://secure.travis-ci.org/polvo/polvo-jade.png)](http://travis-ci.org/polvo/polvo-jade) [![Coverage Status](https://coveralls.io/repos/polvo/polvo-jade/badge.png)](https://coveralls.io/r/polvo/polvo-jade)

[![Dependency Status](https://gemnasium.com/polvo/polvo-jade.png)](https://gemnasium.com/polvo/polvo-jade) [![NPM version](https://badge.fury.io/js/polvo-jade.png)](http://badge.fury.io/js/polvo-jade)

# Install

You won't need to install it since it comes built in in Polvo.

Enjoy.

# Instructions

Just put your `.jade` files in your `input dirs` and it will be ready for use.

Templates are compiled to strict  CJS modules, to require them just use the well
known [CJS pattern](http://nodejs.org/api/modules.html), more
info [here](http://wiki.commonjs.org/wiki/Modules/1.1).

The same resolution algorithm presented in NodeJS will be used.

## Example

````coffeescript
template = require './your/jade/template'

dom = template()
console.log dom
# append it to your document, i.e:
# $('body').append dom
````

# Partials

There's a built in support for partials in Jade, polvo will handle them in a 
particular conventioned way.

Every file starting with `_` won't be compiled alone. Instead, if some other
file that doesn't start with `_` imports or extends it, it will be compiled
within it.

The import tag follows the Jade default syntax.

To include a partial in your `jade`, just:

 1. Name your patial accordingly so it starts with `_`
 1. Calls it from any of your `jade` files by using the `include` or `extends` directive

````jade
 include ./_partial-name-here
 extends ./_partial-name-here
````

Partials are referenced relatively.