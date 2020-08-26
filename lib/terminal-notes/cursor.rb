module TerminalNotes
    class Cursor
        attr_reader :x, :y

        def initialize(x: 0, y: 0)
            @x = x.to_i
            @y = y.to_i
        end

        def moveBy(deltaX = 0, deltaY = 0)
            @x += deltaX
            @y += deltaY
            self
        end

        def moveTo(x: nil, y: nil)
            @x = x unless x.nil?
            @y = y unless y.nil?
            self
        end

        def to_hash
            { x: @x, y: @y }
        end
    end
end