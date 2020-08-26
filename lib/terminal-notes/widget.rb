module TerminalNotes
  class Widget
    attr_reader :window, :width, :height

    TITLE_PADDING = 4

    def initialize(parent:, title:, width: 1, height: 1,
                   x: 0, y: 0, align: :center, valign: :center,
                   border: true)
      @parent = parent
      @title  = title || ""

      @width  = width
      @height = height

      parent_size = @parent.size

      # Relative layout calculation
      remaining_width = @width
      if @width <= 1
        remaining_width = parent_size[:columns] - x
        @width = (@width * remaining_width).to_i
      end

      remaining_height = @height
      if @height <= 1
        remaining_height = parent_size[:lines] - y
        @height = (@height * remaining_height).to_i
      end

      if align == :center
        pos_x = x + (remaining_width - @width) / 2
        @title_x = (@width - @title.size) / 2
      elsif align == :right
        pos_x = (remaining_width - @width)
        @title_x = @width - @title.size - TITLE_PADDING
      else
        pos_x = x # do nothing
        @title_x = TITLE_PADDING
      end

      if valign == :center
        pos_y = y + (remaining_height - @height) / 2
      elsif valign == :bottom
        pos_y = y + (remaining_height - @height)
      else
        pos_y = y # do nothing
      end

      @position = Cursor.new(x: pos_x, y: pos_y)

      @window = Rurses::Window.new(
        lines: @height, columns: @width,
        x: @position.x, y: @position.y)

      @has_border = border

      # @window.refresh_in_memory
    end

    def redraw
      @window.clear
      draw
    end

    def draw
      old_cursor = @window.cursor_xy

      # Draw title
      if @has_border || !@title.empty?
        @window.draw_border
        @window.move_cursor(x: @title_x, y: 0)
        @window.draw_string(" #{@title} ")
      end

      yield if block_given?

      @window.move_cursor(old_cursor)
      @window.refresh_in_memory
    end

    def focus
    end

    def resize
      calculate_and_draw
    end

    private

    def calculate_and_draw(new_window: false)
      @window.clear
      @window.refresh_in_memory
    end
  end
end
