# dotfiles

Various shell initialization scripts, to sync between machines.

## Installation

Review `install.sh` and the install file for your OS (Darwin is for MacOS) to
be sure you want your system to be configured identically to mine!

Run `install.sh` to install everything automatically.

For partial installs, use the following command line options:

| Option | Function |
|:------:|:---------|
|   -h   | Print the help text |
|   -g   | Run in GUI mode (requires zenity in $PATH) |
|   -y   | Answer Yes to all prompts |
|   -a   | Enable Android Studio configuration changes |
|   -c   | Suppress configuration changes |
|   -f   | Suppress font installation |
|   -p   | Suppress package updates |
|   -v   | Suppress VSCode extension installation |
|   -x   | Suppress XCode initialization (OS X only) |
|   -C   | Only run configuration changes |
|   -F   | Only run font installation |
|   -P   | Only run package updates |
|   -V   | Only run VSCode extension installation |
|   -X   | Only run XCode initialization  (OS X only) |

### Manual (Minimal) Installation

To install manually:

* Copy the files in `bin` to `$HOME/bin`
* Copy the files in `bin_Darwin` to `$HOME/bin` (OS X only)
* Copy the files in `fonts` to the appropriate location (depends on OS)
* Copy the files in `vim` to `$HOME/.vim`
* Copy the files in `bashd` to `$HOME/.bashd`
* Copy `editorconfig` to `$HOME`
* Copy `dircolors` to `$HOME/.dircolors`
* Add the following line to the end of your .bash_profile or .bashrc file:

```bash
    [ -f ~/.bashd/extra.bashrc ] && source ~/.bashd/extra.bashrc
```

* Restart your terminal

This does not install the VS Code extensions, package updates, or initialize XCode. See the individual install scripts for details on how to handle these.

## License

Unless specified below, this source code is Public Domain. See LICENSE.PD

### Exceptions

bin/coloredlogcat.py is released under the Apache License, Version 2.0. See LICENSE.APACHE

### Fonts

Unless otherwise specified, the included fonts are licensed under the SIL Open Font License (OFL), Version 1.1.

If a font is dual licensed under the SIL OFL and another license, I have elected to distribute it under the SIL OFL.

#### Fonts not licensed under the SIL OFL

* Abelard, AuntJudy, Barbara Plump, Barbara Svelte, Carolingia, Cry Uncial, and Laramie are freely distributable Freeware.
* Black Chancery is released into the public domain.
* Charter is licensed under the Bitstream Charter permissive license.
* Essays 1743 is licensed under the GNU Lesser General Public License (LGPL), Version 2.1.
* ET Book and Sorts Mill Kis are licensed under the MIT License.
* George Williams and Go fonts are licensed under the Modified (3-clause) BSD License.
* Accanthis ADF, FPL Neu, Gillius ADF, and Ornements ADF are licensed under the GNU General Public License (GPL), Version 2 or later, with font exception.
* Luxi fonts are licensed under the Luxi font license.
* MgOpen fonts are licensed under the Magenta font license.
* Arimo, Caladea, Cousine, Droid Sans, Droid Sans Mono, Droid Sans Mono Dotted, Droid Sans Mono Slashed, Droid Serif, Meslo LG, Roboto, Roboto Condensed, Roboto Mono, Roboto Slab, Smokum, and Tinos are licensed under the Apache License, Version 2.0.
* TeX Gyre fonts are licensed under the GUST Font License.
* Ubuntu, Ubuntu Condensed, and Ubuntu Mono are licensed under the Ubuntu Font License, Version 1.0.
* URW fonts are licensed under the Aladdin Free Public License.

For more details on font licenses, see the individual LICENSE files in each font's folder.
