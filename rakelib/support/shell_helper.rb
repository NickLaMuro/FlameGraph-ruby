# == Shell Helper
#
# An augment module of the `rake`'s FileUtils patch of `sh`.  Can be included
# by including in a Rakefile or Class/Module by doing:
#
#   require 'rake/fileutils'
#   require 'support/shell_helper'
#
#   include FileUtils
#   include ShellHelper
#
# This makes the `run` method accessible for the given context.
#
module ShellHelper

  module_function

  # :call-seq:
  #   run cmd, *args
  #   run cmd, *args, &block
  #   run cmd, *args, silent &block
  #   run cmd, *args, output_io &block
  #   run cmd, *args, output_io, silent &block
  #
  # Runs a `cmd` and it's `args` using `.system`
  #
  # This is a wrapper around rake's own `sh` method, with the output suppressed
  # by default, and the command being run echo'ed to STDOUT.
  #
  # If a block is passed, it includes a `true`/`false` "ok" argument and a
  # `exitcode` as block variables that can react to the command in a customized
  # fashion.
  #
  # If `silent` is passed as boolean (or the SILENT contsant), then the command
  # is not echo'd to the terminal.
  #
  # If `output_io` is passed and is a IO-like object, then the output is saved
  # into the terminal, and is then returned as the result when the method is
  # completed.  Otherwise `nil` will be returned.
  #
  def run cmd, *args, &block
    silent = args.pop if [true, false, nil].include? args.last
    output = args.pop if args.last.class <= IO

    puts ">>>>> #{cmd} #{args.join(' ')}" unless silent

    sh cmd, *args, *sh_opts(output), &block

    output
  ensure
    output.rewind if output
  end

  def sh_opts output = nil
    output ||= File::NULL
    [
      { [:out, :err] => output },
      { :verbose     => false  }
    ]
  end
  private_class_method :sh_opts
end
