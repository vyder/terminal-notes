require "ffi-ncurses"

require_relative "rurses/version"
require_relative "rurses/panel_stack"
require_relative "rurses/window"

module Rurses
  SPECIAL_KEYS = Hash[
    FFI::NCurses::KeyDefs
      .constants
      .select { |name| name.to_s.start_with?("KEY_") }
      .map    { |name|
        [ FFI::NCurses::KeyDefs.const_get(name),
          name.to_s.sub(/\AKEY_/, "").to_sym ]
      }
  ]

  module_function

  def curses
    FFI::NCurses
  end

  def program(modes: [ ])
    @stdscr = Window.new(curses_ref: curses.initscr, standard_screen: true)
    @stdscr.change_modes(modes)
    yield(@stdscr)
  ensure
    curses.endwin
  end

  def stdscr
    @stdscr
  end

  def get_key
    case (char = curses.getch)
    when curses::KeyDefs::KEY_CODE_YES..curses::KeyDefs::KEY_MAX
      SPECIAL_KEYS[char]
    when curses::ERR
      nil
    when 1
      :CTRL_A
    when 5
      :CTRL_E
    when 10
      :ENTER
    when 11
      :CTRL_K
    when 14
      :CTRL_N
    when 23
      :CTRL_W
    when 24
      :CTRL_X
    when 127
      :BACKSPACE
    else
      char.chr
    end
  end

  def update_screen
    curses.doupdate
  end
end
