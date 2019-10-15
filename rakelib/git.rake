rakelib = File.expand_path "..", __FILE__
$LOAD_PATH.unshift(rakelib) unless $LOAD_PATH.include?(rakelib)

require 'rake'
require 'rake/tasklib'
require 'tmpdir'

require 'support/rake_constants'
require 'support/shell_helper'

class GitError < StandardError
  def initialize cmd, output
    msg = generate_message cmd, output
    super msg
  end

  private

  def generate_message command, output
    output.rewind if output.respond_to? :rewind

    out = output
    out = output.string if output.kind_of? StringIO
    out = output.read   if output.kind_of? IO
    cmd = command
    cmd = cmd.join(" ") if command.kind_of? Array

    "`#{cmd}' failed with the following output:\n\n#{out}\n"
  end
end

module Git
  SILENT = true

  extend FileUtils
  extend ShellHelper

  module_function

  def tag tag, msg
    git_tags       = run "git", "tag", git_output_dir.join("git-tags").open("w+"), SILENT
    already_tagged = git_tags.read.split("\n").include?(FLAMEGRAPH_VERSION_TAG)

    unless already_tagged
      begin
        git "tag", "-m", msg, tag
        git "push"
        git "push", "--tags"
      rescue => e
        puts "Un-tagging due to error..."
        run "git", "tag", "-d", version_tag, SILENT
        raise e
      end
    end

  end

  # Ensure there isn't an dirty index
  def clean?
    git "diff", "--exit-code", SILENT do |ok, _|
      fail "Git: index is not clean!" unless ok
    end
  end

  # Ensure there are no files staged for a commit
  def commited?
    git "diff-index", "--quiet", "--cached", "HEAD", SILENT do |ok, _|
      fail "Git: some changes are not committed!" unless ok
    end
  end

  # Ensure we are on the right tag
  def on_current_release_tag? expected_version_tag
    git "describe", SILENT do |ok, _, tag_check_out|
      tag_check_out.rewind
      current_tag = tag_check_out.readlines.first.chomp

      if !ok or current_tag != expected_version_tag
        fail "Git: not on the proper tag!"
      end
    end
  end

  def git *git_args, &block
    silent          = git_args.pop if [true, false, nil].include? git_args.last
    git_cmd         = ["git"] + git_args
    output_filename = git_cmd.join(" ").gsub(/[^a-zA-Z0-9 ]/, '').tr(' ', '-')
    cmd_output      = git_output_dir.join(output_filename).open "w+"

    if block_given?
      wrapper_block = lambda { |ok, _| block.call ok, git_cmd, cmd_output }
      run *git_cmd, cmd_output, silent, &wrapper_block
    else
      run *git_cmd, cmd_output, silent do |ok, _|
        raise GitError.new(git_cmd, cmd_output) unless ok
      end
    end
  end
  private_class_method :git

  def git_output_dir
    require 'pathname'
    @git_output_dir ||= Pathname.new git_tmpdir
  end
  private_class_method :git_output_dir

  def git_tmpdir
    @git_tmpdir ||= Dir.mktmpdir
  end
end

at_exit { FileUtils.rm_rf Git.git_tmpdir }

namespace :git do
  task :clean do
    Git.clean?
  end

  task :committed do
    Git.commited?
  end

  task :validate_tag do
    Git.on_current_release_tag? FLAMEGRAPH_VERSION_TAG
  end

  task :ok       => [:clean, :committed]
  task :validate => [:ok, :validate_tag]

  task :tag => [:ok] do
    Git.tag FLAMEGRAPH_VERSION_TAG, %Q{"Version #{FLAMEGRAPH_GEMSPEC.version}"}
  end
end
