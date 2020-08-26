# Note Transpose
[![Gem Version](https://badge.fury.io/rb/terminal-notes.svg)](https://badge.fury.io/rb/terminal-notes)
[![Build Status](https://travis-ci.org/vyder/terminal-notes.svg?branch=master)](https://travis-ci.org/vyder/terminal-notes)
[![Inline docs](http://inch-ci.org/github/vyder/terminal-notes.svg?branch=master)](http://inch-ci.org/github/vyder/terminal-notes)

Searchable notes in your terminal! What's not to like?

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Documentation](#documentation)
- [Roadmap](#roadmap)
- [Support](#support)
- [Contributing](#contributing)

## Install

    ❯ gem install terminal-notes

On first run, you will be asked to confirm the destination of your install. It defaults to `~/.notesrc/`.

The main configuration file is located at `~/.notesrc/config`. It's a YAML file.

All your notes are saved in `~/.notesrc/db` as text files.

Additionally, I like to symlink the binary to my `~/bin` folder for ease of access. You can do that with:

    ❯ ln -sn $(which terminal-notes) ~/bin/notes

Make sure you have your `~/bin` in your `PATH` for this to work.

## Usage

    ❯ terminal-notes

TODO: Write this section

## Documentation

You can find the documentation [here](https://vyder.github.io/terminal-notes/)

## Roadmap

Here is my planned roadmap:

(Last updated Aug 26th, 2020)

- [ ] Draw a shortcuts info bar like `nano` has
- [ ] Draw a title bar at the top
- [ ] Implement `.notesrc` and database
- [ ] Create an install flow (as described in the README)
- [ ] Implement responsive layout
- [ ] Implement a better file matcher
- [ ] Create a non fancy mode which works better in smaller terminal screens
- [ ] Update status line to display:
    - Matcher
- [ ] Abstract out UI work to Layout module that is stateful and tracks x,y widget positions

Future:
- Implement file previews with `tty-markdown` when in full screen mode

## Support

Please [open an issue](https://github.com/vyder/terminal-notes/issues/new) for support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/vyder/terminal-notes/compare/).
