require 'fuzzy_match'

module TerminalNotes
    class FileList < Widget
        WIDTH  = 1

        EXTENSIONS     = ['.md', '.txt']
        DEFAULT_EDITOR = "nano"

        CONTENT_PADDING = 2
        FILE_INDICATOR  = "❯ "
        INTER_COL_GAP   = "  "

        MATCHERS = [:regex, :fuzzy]

        def initialize(parent:, height:, y:, directory:,
                       extensions: EXTENSIONS)
            super(parent: parent, title: "Files",
                  width: WIDTH, height: height, y: y)

            @content_start = Cursor.new(x: 0, y: CONTENT_PADDING)

            # Find all the files that match specified extensions
            @all_files = Dir.glob("#{directory}/*")
            @all_files = @all_files.find_all do |f|
                f.match /(#{EXTENSIONS.join("|")})$/
            end
            @all_files = @all_files.map do |f|
                {
                    name: f.gsub("#{directory}/", ''),
                    path: f,
                    date: "Jun 24, 2012",
                    time: "05:32pm"
                }
            end
            @filtered_files = @all_files

            @fuzzy_matcher = FuzzyMatch.new(@all_files, read: :name)
            @curr_matcher  = 0

            @current_line = 0
            @has_focus    = false

            @on_file_opened_delegates = []

            draw
        end

        # TODO
        def focus
            @has_focus = true
            draw
        end

        def unfocus
            @has_focus = false
            draw
        end

        def draw
            super do
                # Calculate where to start drawing the table
                #
                table_width = 0

                # Calculate NAME col width
                longest_file = @all_files.max { |a, b| a[:name].size <=> b[:name].size }
                if longest_file.nil?
                    name_col_width = 10
                else
                    name_col_width = 2 + longest_file[:name].size
                end

                # Calculate DATE col width, e.g. Jun 24, 2012
                date_col_width = 12

                # Calculate TIME col width, e.g. 05:24pm
                time_col_width = 7

                table_width += name_col_width + INTER_COL_GAP.size
                table_width += date_col_width + INTER_COL_GAP.size
                table_width += time_col_width

                # Move cursor to center the table
                cursor = @content_start.dup
                cursor.moveTo(x: (@parent.size[:columns] - table_width) / 2)
                @window.move_cursor(cursor)

                # Start actually drawing
                #

                # Draw header
                line  = "NAME".ljust(name_col_width) + INTER_COL_GAP
                line += "DATE".ljust(date_col_width) + INTER_COL_GAP
                line += "TIME".ljust(time_col_width)
                @window.draw_string(line)

                # Move cursor back to accomodate the file indicator
                cursor.moveBy(-FILE_INDICATOR.size, 1)
                @window.move_cursor(cursor)

                no_indicator = " " * FILE_INDICATOR.size

                index = 0
                @filtered_files.each do |file|
                    line  = no_indicator
                    line += file[:name].ljust(name_col_width) + INTER_COL_GAP
                    line += file[:date].rjust(date_col_width) + INTER_COL_GAP
                    line += file[:time].rjust(time_col_width)

                    @window.draw_string(line)

                    # Draw the arrow
                    if @has_focus && index == @current_line
                        @window.move_cursor(cursor)
                        @window.draw_string(FILE_INDICATOR)
                    end

                    cursor.moveBy(0, 1)
                    @window.move_cursor(cursor)

                    index += 1
                end

                clear_line = no_indicator + " " * table_width
                while index < @all_files.size
                    @window.draw_string(clear_line)
                    cursor.moveBy(0, 1)
                    @window.move_cursor(cursor)

                    index += 1
                end

            end
        end

        def on_key key
            return unless @has_focus

            case key
            when "j"
                scroll_down
            when "k"
                scroll_up
            when :ENTER
                open_current
            else
            end

            draw
        end

        def filter pattern
            old_file_list = @filtered_files

            if pattern.empty?
                @filtered_files = @all_files
            else
                matcher_type = MATCHERS[@curr_matcher]
                case matcher_type
                when :regex
                    @filtered_files = @all_files.find_all do |f|
                        f[:name].match /#{pattern}/
                    end
                when :fuzzy
                    @filtered_files = @fuzzy_matcher.find_all(pattern)
                else
                    raise "Unknown Matcher! '#{matcher_type}'"
                end
            end

            # If the file list has changed, reset current line marker
            @current_line = 0 unless old_file_list == @filtered_files

            draw
        end

        def toggle_matcher
            @curr_matcher += 1
            @curr_matcher  = 0 if @curr_matcher >= MATCHERS.size
        end

        def on_file_opened &block
            @on_file_opened_delegates << block
        end

        def notify_file_opened(file)
            @on_file_opened_delegates.each do |delegate|
                delegate.call(file)
            end
        end

        private

        def open_current
            file = @filtered_files[@current_line]
            notify_file_opened(file[:path])
        end

        def editor
            # %x(echo $EDITOR).chomp || DEFAULT_EDITOR
            ENV['EDITOR'] || DEFAULT_EDITOR
        end

        def scroll_down
            if @current_line < (@filtered_files.size - 1)
                @current_line += 1
            end
        end

        def scroll_up
            if @current_line > 0
                @current_line -= 1
            end
        end
    end
end