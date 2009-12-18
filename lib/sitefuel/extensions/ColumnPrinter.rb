#
# File::      ColumnPrinter.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Little utility for printing terminal output in columns.
#
# Note that this utility buffers per-row, and so it has to decide column widths
# as soon as the first row is printed.
#
# TODO: there are a lot of off-by-one errors here. They don't matter for
#       SiteFuel purposes so we haven't fixed them... but we should. ;-)
#
# == Examples
#
#  printer = ColumnPrinter.new([15, :span, 20])
#  printer.row 'some number', 'this gets expanded out', 'cell 3'
#

require 'sitefuel/extensions/StringFormatting'

class ColumnPrinter
  # specify the width for the entire grid
  attr_accessor :column_widths

  # what character should be used
  attr_accessor :corner_piece

  # what character should be used to horizontally separate cells
  attr_accessor :horizontal_divider_piece

  # what character should be used to vertically separate rows. If =nil= or
  # '' rows will not be separated.
  attr_accessor :vertical_divider_piece

  attr_accessor :allow_resizing

  # specifies the minimum width for a column
  attr_accessor :minimum_column_width

  
  def initialize(column_widths, output_width = :automatic)
    mode :aligned

    self.column_widths = column_widths
    
    @output_width = output_width

    # we disallow resizing since the constant checking *really* slows
    # printing down
    @allow_resizing = false
    
    @minimum_column_width = 5

    compute_absolute_column_widths
    alignment(:left)
  end


  # sets the alignment for the columns
  def alignment(columns)
    case columns
      when Symbol
        @column_alignment = Array.new(column_count, columns)

      when Array
        @column_alignment = columns
    end
  end


  # gives the number of columns in this printer
  def column_count
    self.column_widths.length
  end


  # set the mode of the columns
  # :aligned::  columns are aligned, but there are no explicit dividers
  # :divided::  columns are aligned and separated by vertical dividers
  # :cells::    columns are aligned and cells are separated by horizontal and
  #             vertical dividers.
  def mode(kind)
    case kind
      when :aligned
        @horizontal_divider_piece = ' '
        @vertical_divider_piece   = ''
        @corner_piece             = ''

      when :divided
        @horizontal_divider_piece = '|'
        @vertical_divider_piece   = ''
        @corner_piece             = ''

      when :cells
        @horizontal_divider_piece = '|'
        @vertical_divider_piece   = '-'
        @corner_piece             = '+'

      else
        raise StandardError.new("Unknown kind of mode for ColumnPrinter: #{kind}")
    end
  end


  def output_width=(new_width)
    if allow_resizing
      @output_width = new_width
      compute_absolute_column_widths
    else
      # don't do anything for now; TODO should raise a message
    end
  end


  def output_width
    if @output_width == :automatic
      TerminalInfo.width
    else
      @output_width
    end
  end


  # given the mixture of absolute, relative, and spanning widths computes the
  # actual width of each column
  #
  # == Method
  # * start with the output width and allocate space for each absolute
  #   sized column
  # * of the space remaining, allocate that to relative sized columns
  # * divy up any remaining space evenly between :span columns
  def compute_absolute_column_widths
    # we remove one to make room for the leading space
    unallocated_width = output_width - 1

    relative_columns = []
    span_columns = []

    @absolute_column_widths = Array.new(column_widths.length)

    # group relative sizes and span sizes, allocate out space to absolute sizes
    column_widths.each_with_index do |width, index|
      case width
        when :span
          # store for later computation
          span_columns << [index, :span]

        when Float
          relative_columns << [index, width]

        when Fixnum
          @absolute_column_widths[index] = actual_width(width)
          unallocated_width -= actual_width(width) + 1
      end
    end

    # allocate out space to relative sizes
    relative_columns.each do |entry|
      real_size = actual_width(unallocated_width * entry.last)
      unallocated_width -= real_size + 1

      @absolute_column_widths[entry.first] = real_size
    end

    # allocate out space to span sizes
    num_spans = span_columns.length.prec_f

    # if there are no spans we're done
    if num_spans < 1
      return @absolute_column_widths
    end
    
    real_size = actual_width((unallocated_width - num_spans) / num_spans)
    span_columns.each do |entry|
      @absolute_column_widths[entry.first] = real_size
    end
    
    @absolute_column_widths
  end


  # if the given width is less than #minimum_column_width, gives
  # #minimum_column_width. Otherwise gives floor() of the given width
  def actual_width(width)
    if width < minimum_column_width
      minimum_column_width
    else
      width.floor
    end
  end


  def row(*values)
    write format_row(*values)
  end


  # aligns a cell based on the specification
  def align_cell(column_index, value, width)
    case @column_alignment[column_index]
      when :left
        value.visual_ljust(width)

      when :right
        value.visual_rjust(width)

      when :center
        value.visual_center(width)
    end
  end


  # formats a new row
  def format_row(*values)

    # check if the output width has changed
    if allow_resizing and output_width == :automatic
      current_width = TerminalInfo.width
      if current_width != output_width
        output_width = current_width
      end
    end

    line = ""

    # dump out the row
    values.each_with_index do |cell,index|
      cell_width = @absolute_column_widths[index]
      line << horizontal_divider_piece
      line << align_cell(index, cell.to_s.cabbrev(cell_width), cell_width)
    end
    line << horizontal_divider_piece
    line << row_divider

    line
  end


  def row_divider
    if vertical_divider_piece == nil
      return ''
    end

    line = ""
    line << corner_piece
    @absolute_column_widths.each do |width|
      line << vertical_divider_piece * width
      line << corner_piece
    end

    line
  end


  # outputs an already formatted line. Eventually this will allow writing to
  # strings and such; but for now just an alias for #puts
  def write(line)
    puts line
  end

  
  # print a divider for the entire length of the grid
  # optionally a function or Proc may be specified for processing the divider
  # (to change it's color or weight, for example)
  def divider(character = '=', processor = nil)
    div = character * output_width

    if processor
      write processor.call(div)
    else
      write div
    end
  end
end