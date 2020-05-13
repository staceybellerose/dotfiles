# dotfiles

Various shell initialization scripts, to sync between machines.

## Installation

Review `install.sh` and the install file for your OS (Darwin is for MacOS) to
be sure you want your system to be configured identically to mine!

Run `install.sh` to install everything automatically.

### Manual Installation

To install manually:

* Copy the files in `bin` to `$HOME/bin`
* Copy the files in `fonts` to the appropriate location (depends on OS)
* Copy the files in `vim` to `$HOME/.vim`
* Copy the files in `bashd` to `$HOME/.bashd`
* Add the following line to the end of your .bash_profile or .bashrc file:

```bash
    [ -f ~/.bashd/extra.bashrc ] && . ~/.bashd/extra.bashrc
```

* Restart your terminal

## License

bin/coloredlogcat.py is released under the Apache License, Version 2.0. See LICENSE.APACHE

### Font licensing

* Inconsolata and Source Code Pro are licensed under the SIL Open Font License, Version 1.1.
* MesloLG is licensed under the Apache License, Version 2.0.
* Monoid is dual licensed under the MIT and the SIF Open Font License, Version 1.1.
* Roboto, Roboto Condensed, Roboto Mono, and Roboto Slab are licensed under the Apache License, Version 2.0.

For more details on font licenses, see the individual LICENSE files in each font's folder.

Everything else is Public Domain. See LICENSE.PD
