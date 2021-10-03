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

* [Cabin][cabin], [Cabin Sketch][cabinsketch], [Cascadia Mono][cascadia], [Dancing Script][dancing], [EB Garamond][eb], [Fantasque Sans Mono][fantasque], [FontAwesome][awesome], [Goudy Bookletter 1911][bookletter], [Humor Sans][xkcd], [Inconsolata][inconsolata], [Inter][inter], [Isabella][isabella], [Libre Baskerville][lbaskerville], [Libre Caslon Text][lcaslon], [Libre Franklin][lfranklin], [Lobster, Lobster Two][lobster], [Merriweather][merriweather], [Milonga][milonga], [Miltonian][miltonian], [Mononoki][mononoki], [Petit Formal Script][petit], [Source Code Pro][sourcecode], [Source Sans Pro][sourcesans], and [Source Serif Pro][sourceserif] are licensed under the SIL Open Font License, Version 1.1.
* [Domitian][domitian] is licensed under your choice of the SIL Open Font License Version 1.1, the GNU Affero General Public License (AGPL) Version 3, LaTeX Project Public License, or any combination thereof.
* [Essays 1743][essays] is licensed under the GNU Lesser General Public License (LGPL), Version 2.1.
* [Meslo LG][meslo] is licensed under the Apache License, Version 2.0.
* [Monoid][monoid] is dual licensed under the MIT and the SIF Open Font License, Version 1.1.
* [Roboto, Roboto Condensed][roboto], [Roboto Mono][robotomono], and [Roboto Slab][robotoslab] are licensed under the Apache License, Version 2.0.
* [Ubuntu][ubuntu] is licensed under the Ubuntu Font License, Version 1.0.

For more details on font licenses, see the individual LICENSE files in each font's folder.

[awesome]: https://fontawesome.com/v4.7/
[bookletter]: https://github.com/theleagueof/goudy-bookletter-1911
[cabin]: https://github.com/impallari/Cabin
[cabinsketch]: https://github.com/impallari/CabinSketch
[cascadia]: https://github.com/microsoft/cascadia-code
[dancing]: https://github.com/impallari/DancingScript
[domitian]: https://github.com/dbenjaminmiller/domitian
[eb]: https://github.com/octaviopardo/EBGaramond12
[essays]: https://www.thibault.org/fonts/essays/
[fantasque]: https://github.com/belluzj/fantasque-sans
[inconsolata]: https://github.com/googlefonts/inconsolata
[inter]: https://github.com/rsms/inter/
[isabella]: https://www.thibault.org/fonts/isabella/
[lbaskerville]: https://github.com/impallari/Libre-Baskerville
[lcaslon]: https://github.com/impallari/Libre-Caslon-Text
[lfranklin]: https://github.com/impallari/Libre-Franklin
[lobster]: https://github.com/impallari/The-Lobster-Font
[merriweather]: https://github.com/SorkinType/Merriweather
[meslo]: https://github.com/andreberg/Meslo-Font
[milonga]: https://fonts.google.com/specimen/Milonga
[miltonian]: https://github.com/impallari/Miltonian
[monoid]: https://github.com/larsenwork/monoid
[mononoki]: https://github.com/madmalik/mononoki
[petit]: https://fonts.google.com/specimen/Petit+Formal+Script
[roboto]: https://github.com/googlefonts/roboto
[robotomono]: https://github.com/googlefonts/RobotoMono
[robotoslab]: https://github.com/googlefonts/robotoslab
[sourcecode]: https://github.com/adobe-fonts/source-code-pro
[sourcesans]: https://github.com/adobe-fonts/source-sans
[sourceserif]: https://github.com/adobe-fonts/source-serif
[ubuntu]: https://design.ubuntu.com/font/
[xkcd]: http://xkcdsucks.blogspot.com/2009/03/xkcdsucks-is-proud-to-present-humor.html
