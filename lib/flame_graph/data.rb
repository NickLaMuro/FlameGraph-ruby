module FlameGraph
  class Data
    LINE_REGEXP = /
      \s+                # Space after stack
      (\d+(?:\.\d*)?)    # First sample size
      \s?                # Optional differencial whitespace
      (\d+(?:\.\d*)?)?   # Optional second sample size
      $                  # End of line
    /x

    attr_reader   :input_io
    attr_reader   :config

    # Config attributes
    attr_reader   :width
    attr_reader   :minwidth
    attr_reader   :xpad

    # Stored data
    attr_reader   :nodes
    attr_reader   :tmp
    attr_reader   :data
    attr_reader   :sorted_data

    # Calculated info
    attr_accessor :timemax
    attr_accessor :time
    attr_reader   :last
    attr_reader   :maxdelta
    attr_reader   :ignored
    attr_reader   :depthmax
    attr_reader   :widthpertime

    def self.digest input_io, config = {}
      new(input_io, config).tap { |data| data.digest! }
    end

    def initialize input_io, config = {}
      @input_io    = input_io
      @config      = config

      @timemax     = config[:total].empty? ? nil : config[:total]
      @width       = config[:width]
      @minwidth    = config[:minwidth]
      @xpad        = config[:xpad]

      @data        = []
      @sorted_data = []

      @last        = []
      @time        = 0
      @ignored     = 0
      @depthmax    = 0
      @maxdelta    = 1

      @nodes       = {}
      @tmp         = {}
    end

    def each
      nodes.each do |id, node|
        func, depth, etime = id.split(";")
        yield func, depth.to_i, node[:stime], etime.to_f, node[:delta]
      end
    end

    # Either loads the nameattr data if it has not already been read, otherwise
    # it just acts as a hash of hashes.
    #
    # The name-attribute file format is a function name followed by a tab then
    # a sequence of tab separated name=value pairs.
    def nameattr
      return @nameattr if defined? @nameattr

      @nameattr = Hash.new({}) # return a empty hash for missing keys

      if File.exist? config[:nameattr]
        File.foreach config[:nameattr] do |line|
          functname, attrstr = line.chomp.split(/\t/, 2)
          raise "Invalid format in #{config[:nameattr]}" unless attrstr
          @nameattr[functname] = attrstr.split(/\t/)
                                        .map { |attrpair| attrpair.split '=' }
                                        .to_h
        end
      end

      @nameattr
    end

    def digest!
      parse!
      process!
      validate!
      prune!
    end

    def parse!
      @input_io.each_line do |line|
        line.chomp!

        if config[:reverse] # reverse if needed
          stack, samples1, samples2 = parse_line line
          samples2.prepend " " if samples2

          @data << "#{data.split(';').reverse.join(';')} #{samples1}#{samples2}"
        else
          @data << line
        end
      end

      if config[:flamechart]
        @sorted_data = @data.reverse
      else
        @sorted_data = @data.sort
      end
    end

    def process!
      delta = nil
      @sorted_data.each do |frame|
        stack, samples1, samples2 = parse_line frame

        unless stack and samples1
          ignored += 1
          next
        end

        delta = nil
        if samples2
          delta    = samples2.to_i - samples1.to_i
          maxdelta = delta.abs  if delta.abs > maxdelta
        end

        # TODO:  broken in original?
        if config[:colors] == "chain"
          parts    = stack.split(";--;")
          newparts = []  # TODO: needed?
          stack    = parts.shift
          stack   += ";--;"

          parts.each do |part|
            part.gsub! %r/;/, "_[w];"
            part += "_[w];"
            newparts.push part
          end

          stack   += parts.join(";--;")
        end

        @last = flow @last, stack.split(';').unshift(''), @time, delta

        @time += (samples2 || samples1).to_i
      end
      flow last, [], @time, delta
    end

    def prune!
      @widthpertime = (width - 2 * xpad).to_f / timemax
      minwidth_time = minwidth / widthpertime

      each do |func, depth, stime, etime, delta|
        raise "missing start for #{id}" if stime.nil?

        if (etime.to_i - stime) < minwidth_time
          nodes.delete "#{func};#{depth};#{etime}"
          next
        end

        @depthmax = depth if depth > @depthmax
      end
    end

    def validate!
      warn "Ignored #{ignored} lines with invalid format" if ignored > 0
      warn "ERROR: No stack counts found"                 unless time

      if time and timemax and timemax < time
        if timemax / time > 0.02 # only warn is significant (e.g., not rounding etc)
          warn "Specified --total #{timemax} is less than actual total #{time}, so ignored\n"
        end
        timemax = nil
      end
      self.timemax ||= time
    end

    private

    def flow last, this, time, delta
      len_a    = last.count - 1
      len_b    = this.count - 1
      len_same = nil

      last.count.times do |i|
        if i > len_b or last[i] != this[i]
          len_same = i
          break
        end
      end
      len_same ||= last.count

      i = len_a
      while i >= len_same
        key = "#{last[i]};#{i}"
        if tmp_data = tmp[key]
          nodes["#{key};#{time}"] = { :stime => tmp_data.delete(:stime) }

          if tmp_data[:delta]
            nodes["#{key};#{time}"][:delta] = tmp_data.delete(:delta)
          end
          tmp.delete(key)
        end

        i -= 1
      end

      i = len_same
      while i <= len_b
        key      = "#{this[i]};#{i}"
        tmp[key] = { :stime => time }

        if delta
          tmp[key][:delta] ||= 0
          tmp[key][:delta]  += i == len_b ? delta : 0
        end
        i += 1
      end

      this
    end

    # Parses a line for input.
    #
    # Returns:
    #
    #   nil:               no match
    #   2 element array:   single frame and number of samples
    #   3 element array:   differentials (frame, samples1, samples2)
    #
    def parse_line line
      if line =~ LINE_REGEXP
        stack    = $`  # pre-match
        samples1 = $1  # first match
        samples2 = $2  # second match
        [stack, samples1, samples2]
      end
    end
  end
end
