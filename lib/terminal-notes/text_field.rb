module TerminalNotes
    class TextField
        attr_reader :text

        DEFAULT_WIDTH = 10
        BREAK_CHARS   = " -_+=".split('')

        def initialize(screen, position: Cursor.new, width: DEFAULT_WIDTH)
            @screen = screen
            @start  = position.dup
            @end    = @start.dup.moveBy(width, 0)
            @width  = width
            @cursor = @start.dup

            @clear_text = " " * @width
            @text = ""

            @on_text_changed_delegates = []
        end

        def on_text_changed &block
            @on_text_changed_delegates << block
        end

        def notify_text_changed
            @on_text_changed_delegates.each do |delegate|
                delegate.call(@text)
            end
        end

        def on_key(key)
            old_text = @text
            case key
            when :BACKSPACE
                @text = @text[0...-1]
                @cursor.moveBy(-1) unless @text.size == (@width - 1)

            when :UP, :DOWN
            when :LEFT
                @cursor.moveBy(-1)

            when :RIGHT
                @cursor.moveBy(1)

            when :CTRL_K
                @text = ""

            when :CTRL_W
                last = @text.size - 2
                while last >= 0
                    break if BREAK_CHARS.include? @text[last]
                    last -= 1
                end
                @text = @text[0...(last+1)]

            when :CTRL_E
                @cursor.moveTo(x: @end.x)

            when :CTRL_A
                @cursor.moveTo(x: @start.x)

            else
                if !key.nil? && !key.is_a?(Symbol) && @text.size < @width
                    @text += key
                    @cursor.moveBy(1)
                end
            end

            # Make sure we don't move cursor too far left
            @cursor.moveTo(x: @start.x) if @cursor.x < @start.x

            # Make sure we don't move cursor too far right
            max_x = @start.x + @text.size
            max_x -= 1 if @text.size == @width
            @cursor.moveTo(x: max_x) if @cursor.x > max_x

            draw

            notify_text_changed if old_text != @text
        end

        def draw
            @screen.move_cursor(@start.to_hash)
            @screen.draw_string(@text.ljust(@width))

            @screen.move_cursor(@cursor.to_hash)
        end
    end
end