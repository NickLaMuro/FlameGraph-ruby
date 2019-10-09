FlameGraph-ruby
---------------

Port of the [FlameGraph][] project by Brendan Gregg to the Ruby programming
language.  This aims completely mirror the output provided by that project, but
be written purely in Ruby.

If you are looking for the similarly named gem by Sam Saffron, that can be
found at https://github.com/SamSaffron/flamegraph

While the latter project has it's perks, I personally prefer the SVG and
stackcollapsed form of the flamegraph provided by the original, versus the
chronological and "javascript app" version provided by the existing
`flamgegraph` gem.  However, with some [recent changes][flamechart PR] to the
original (and this gem as well), this supports the chronological output now as
well.

Additionally, this gem is **not** going to provide features for capturing data,
but simply for taking stackcollapse data and converting it into a flamegraph SVG,
unlike the previously mentioned `flamegraph` gem.


Installation
------------

(#Soon™)

Add this line to your application's Gemfile:

```ruby
gem 'flamegraph-ruby'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install flamegraph-ruby
```


Usage
-----

This gem includes a `bin/flamegraph.rb` script for easy usage via the terminal.
Once installed, you should be able to use `flamegraph.rb` as you would have
`flamegraph.pl`.

In addition, this gem works as a library, so you can use each of the components
independently, and add additional functionality in ways that the original
project could not.

More documentation to come, but an example usage script can be found below:

```ruby
require 'flame_graph'

config          = FlameGraph::Config::DEFAULTS.dup
FlameGraph::Config.set_default_title config

data_file       = File.open("my_stackprof.stackcollapse")
flamegraph_data = FlameGraph::Data.new(config, data_file)
flamegraph_data.digest!

config[:data]   = flamegraph_data

svg = FlameGraph::SVG.new(config)
File.write "example.svg", svg.draw!
```


Vendoring
---------

When I make a new release, I will most likely include the vendored lib/exe
forms, but if you wish to build your own, there are two rake tasks available to
auto combine the source files for you to do this:

```console
$ rake vendorize:lib
$ rake vendorize:exe
```

The former will build the project as a lib, and the second will add extra
functionality so it can be run as a single file CLI script.

You are free (as far as I am concerned) to distribute this in your project, but
make sure you understand the terms and conditions of the LICENSE before doing
so, since this project has inherited the [original project's][FlameGraph]
LICENSE.


Development
-----------

This gem has zero dependencies, so cloning the project and a modern version of
ruby is all you need. Then, run `rake test` to run the tests. You can also run
`rake console` for an interactive prompt that will allow you to experiment.


Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/NickLaMuro/FlameGraph-ruby.


License
-------

The gem is available as open source under the terms of as the original
[FlameGraph][] project using the [CDDL][] License.

[CDDL]:          http://opensource.org/licenses/CDDL-1.0
[FlameGraph]:    https://github.com/brendangregg/FlameGraph
[flamechart PR]: https://github.com/brendangregg/FlameGraph/pull/179
