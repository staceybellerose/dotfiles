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
|   -c   | Suppress configuration changes |
|   -f   | Suppress font installation |
|   -p   | Suppress package updates |
|   -v   | Suppress VSCode extension installation |
|   -x   | Suppress XCode initialization (OS X only) |

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
    [ -f ~/.bashd/extra.bashrc ] && . ~/.bashd/extra.bashrc
```

* Restart your terminal

This does not install the VS Code extensions, package updates, or initialize XCode. See the individual install scripts for details on how to handle these.

## License

Unless specified below, this source code is Public Domain. See LICENSE.PD

### Exceptions

bin/coloredlogcat.py is released under the Apache License, Version 2.0. See LICENSE.APACHE

### Fonts

Unless otherwise specified, the included fonts are licensed under the SIL Open Font License, Version 1.1.

* Charter is licensed under the Bitstream Charter permissive license.
* Domitian is licensed under your choice of the SIL Open Font License Version 1.1, the GNU Affero General Public License (AGPL) Version 3, LaTeX Project Public License, or any combination thereof.
* Essays 1743 is licensed under the GNU Lesser General Public License (LGPL), Version 2.1.
* ET Book is licensed under the MIT License.
* Accanthis ADF, FPL Neu, Gillius ADF, and Ornements ADF are licensed under the GNU General Public License (GPL), Version 2 or later, with font exception.
* Luxi fonts are licensed under the Luxi font license.
* Meslo LG is licensed under the Apache License, Version 2.0.
* Monoid is dual licensed under the MIT License and the SIF Open Font License, Version 1.1.
* Roboto, Roboto Condensed, Roboto Mono, and Roboto Slab are licensed under the Apache License, Version 2.0.
* Sorts Mill Kis is licensed under the MIT License.
* TeX Gyre fonts are licensed under the GUST Font License.
* Ubuntu is licensed under the Ubuntu Font License, Version 1.0.
* URW fonts are licensed under the Aladdin Free Public License.

For more details on font licenses, see the individual LICENSE files in each font's folder.
