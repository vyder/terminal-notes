module TerminalNotes
    class InfoBar < Widget
        HEIGHT = 3

        def initialize(config: {}, parent:, &block)
            super(parent: parent, title: "", height: HEIGHT,
                  y: (parent.size[:lines] - HEIGHT), border: false)

            @get_context = block
            draw
        end

        def draw
            super do
                context = @get_context.call
                title = "Mode: #{context[:mode].to_s.capitalize}"

                cursor = Cursor.new(x: (@parent.size[:columns] - title.size) / 2,
                                    y: 0)
                @window.move_cursor(cursor)
                @window.draw_string(title)
            end
        end
    end
end