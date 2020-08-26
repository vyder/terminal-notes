module TerminalNotes
    class SearchField < Widget
        WIDTH  = 0.5
        HEIGHT = 5
        POS_X = 0
        POS_Y = 1
        ALIGN = :center

        def initialize(parent:)
            super(parent: parent, title: "Search",
                  width: WIDTH, height: HEIGHT,
                  x: POS_X, y: POS_Y,
                  align: ALIGN)

            @text_field = TextField.new(@parent,
                position: @position.dup.moveBy(2, 2),
                width:    @width - 4)

            @has_focus = false

            draw
        end

        def text
            @text_field.text
        end

        def focus
            @has_focus = true
            @text_field.draw
        end

        def unfocus
            @has_focus = false
        end

        def on_text_changed &delegate
            @text_field.on_text_changed { |p| delegate.call(p) }
        end

        def on_key key
            return unless @has_focus
            @text_field.on_key(key)
        end
    end
end