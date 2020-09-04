require_relative 'terminal-notes/rurses'

require_relative 'terminal-notes/version'
require_relative 'terminal-notes/cursor'
require_relative 'terminal-notes/widget'
require_relative 'terminal-notes/text_field'
require_relative 'terminal-notes/search_field'
require_relative 'terminal-notes/file_list'
require_relative 'terminal-notes/info_bar'

module TerminalNotes
    class App
        @has_initialized = false

        def start(config)
            directory = config[:directory]

            Rurses.program(modes: %i[c_break no_echo keypad]) do |screen|
                @screen = screen

                @widgets = []

                @search_field = SearchField.new(parent: @screen)
                @widgets << @search_field

                @info_bar = InfoBar.new(parent: @screen) { get_context }
                @widgets << @info_bar

                padding = 2

                # file_list_height = screen.size[:lines]
                #                     - @search_field.height
                #                     - @info_bar.height
                #                     - padding
                file_list_height = 40
                @file_list = FileList.new(parent: @screen,
                                          height: file_list_height,
                                          y: @search_field.height + padding,
                                          directory: directory)
                @widgets << @file_list

                # Register the text_field filter as a delegate
                # of the search field
                @search_field.on_text_changed do |pattern|
                    @file_list.filter(pattern)
                end

                # Register file open handler
                @file_list.on_file_opened do |file|
                    open_file(file)
                end

                # A PanelStack handles how windows are drawn
                # over each other - i.e. overlapping
                #
                # I'm not really using this ability, however, in
                # Rurses, the PanelStack seems to be the only way
                # to delete/deallocate a window completely
                #
                @panels = Rurses::PanelStack.new
                @widgets.each { |widget| @panels.add(widget.window) }
                @panels.refresh_in_memory

                # Events
                # watch_for_resize

                # Set initial state
                set_context :search

                # Actually draw the screen
                # @panels.refresh_in_memory
                Rurses.update_screen

                @has_initialized = true

                loop do
                    key = Rurses.get_key

                    if @context == :browse
                        case key
                        when "q", :CTRL_X
                            break # quit
                        when "m"
                            @file_list.toggle_matcher
                            @file_list.filter(@search_field.text)

                        when "\t", "/"
                            set_context :search
                        else
                            @file_list.on_key(key)
                        end
                    else
                        case key
                        when :CTRL_X
                            break # quit
                        when "\t", :ENTER
                            set_context :browse
                        else
                            @search_field.on_key(key)
                        end
                    end

                    # When all the downstream widgets are done updating
                    # in-memory, actually redraw the screen
                    # @panels.refresh_in_memory
                    Rurses.update_screen
                end

                @screen.move_cursor(x: 0, y: 0)
            end
        end

        def set_context context
            @context = context

            if @context == :browse
                Rurses.curses.curs_set(0)
                @search_field.unfocus
                @file_list.focus

            elsif @context == :search
                Rurses.curses.curs_set(1)
                @file_list.unfocus
                @search_field.focus

            end

            @info_bar.draw
        end

        def get_context
            { mode: @context }
        end

        def open_file(file)
            system(editor, file)
            redraw

            # Hack to redraw focus correctly
            # TODO: Figure out why this works
            set_context :search
            set_context :browse
        end

        def editor
            ENV['EDITOR'] || DEFAULT_EDITOR
        end

        # This method can be invoked independent of the wait for
        # keyboard input loop, so explicitly call for a screen
        # update after widgets have been drawn
        def redraw(resize: false)
            return unless @has_initialized

            @widgets.each(&:redraw)
            # @widgets.each do |widget|
                # widget.window.clear
                # @panels.remove(widget.window)
                # widget.draw(resize: resize)
                # @panels.add(widget.window)
            # end

            set_context @context

            @panels.refresh_in_memory
            Rurses.update_screen
        end

        def watch_for_resize
            # SIGWINCH
            #   The SIGWINCH signal is sent to a process when its
            #   controlling terminal changes its size (a window change).
            Signal.trap(:SIGWINCH) { redraw(resize: true) }
        end
    end
end
