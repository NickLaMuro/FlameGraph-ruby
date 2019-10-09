require 'fileutils'
require 'pathname'

class Vendorize

  PROJECT_ROOT = File.expand_path File.join('..', '..', '..'), __FILE__

  attr_accessor :lib
  attr_accessor :output
  attr_accessor :project_root

  def self.as_lib
    new.as_lib
  end

  def self.as_exe
    new.as_exe
  end

  def initialize
    @project_root = Pathname.new PROJECT_ROOT
    @lib          = @project_root.join "lib", "flame_graph"
  end

  def as_lib
    @output = File.open project_root.join("pkg", "flamegraph-ruby.rb"), "w"

    add_library_files

    output.close
  end

  def as_exe
    @output = File.open project_root.join("pkg", "flamegraph.rb"), "w"

    output.puts "#!/usr/bin/env ruby"
    output.puts "#"

    add_library_files

    add_file lib.join("config", "options.rb")
    add_file lib.join("cli.rb")

    output.puts
    output.puts "FlameGraph::CLI.run"

    output.close

    FileUtils.chmod "+x", output.path
  end

  private

  def add_library_files
    add_file lib.join("version.rb")

    add_file lib.join("color.rb")
    add_file lib.join("color", "themes.rb")
    add_file lib.join("color", "theme", "aqua.rb")
    add_file lib.join("color", "theme", "blue.rb")
    add_file lib.join("color", "theme", "chain.rb")
    add_file lib.join("color", "theme", "green.rb")
    add_file lib.join("color", "theme", "hot.rb")
    add_file lib.join("color", "theme", "io.rb")
    add_file lib.join("color", "theme", "java.rb")
    add_file lib.join("color", "theme", "js.rb")
    add_file lib.join("color", "theme", "mem.rb")
    add_file lib.join("color", "theme", "orange.rb")
    add_file lib.join("color", "theme", "perl.rb")
    add_file lib.join("color", "theme", "purple.rb")
    add_file lib.join("color", "theme", "red.rb")
    add_file lib.join("color", "theme", "wakeup.rb")
    add_file lib.join("color", "theme", "yellow.rb")
    add_file lib.join("color", "palette.rb")

    add_file lib.join("config.rb")
    add_file lib.join("data.rb")

    add_template "script.js.erb"

    add_file lib.join("svg.rb") do |line|
      case line
      when /^\s*template_(dir|file)\s*=.*/
        false
      when /^(\s*)template_data\s*=.*/
        %Q'#{$1}template_data = Object.const_get("TEMPLATE_\#{template.tr(".", "_").upcase}_ERB")'
      else
        line
      end
    end
  end

  def add_file filepath
    file_content = ""

    filepath.each_line do |line|
      next if line =~ /^\s*require\s+['"]flame_graph/ # don't include lib requires

      if block_given?
        line_content = yield line
        file_content << line_content if line_content
      else
        file_content << line
      end
    end

    output.puts
    output.puts file_content
    output.puts
  end

  def add_template template
    constant = "TEMPLATE_#{template.tr(".", "_").upcase}"
    filepath = lib.join("templates", template)

    output.puts
    output.puts "#{constant} = <<-#{constant}"
    output.puts filepath.read
    output.puts "#{constant}"
    output.puts
  end
end
