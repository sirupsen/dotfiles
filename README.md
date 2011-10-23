# Sirupsen's Dotfiles

These are my dotfiles, that I have tweaked and used for the past two years.

# Software

Relevant to these configuration files are..

* OS
  - OS X Lion
* Terminal
  - iTerm 2
* Shell
  - `bash`
* Text editor
  - `vim`
* Version control
  - `git`
* Terminal multiplexer (basically what I use as my in-terminal tiling)
  - `tmux`
* Email client
  - `mutt`

# How I store my dotfiles

Here's how I sync my dotfiles across machines.

They're all in `~/Dropbox/dotfiles`.

Then I use [Homesick][homesick] to handle the symlinking from this directory to
`~/` for two reasons:

* I don't have to reinvent the wheel
* I can easily share my configuration
    - And get up and running remotely in a matter of seconds

I cheat `homesick` into thinking I cloned my dotfiles via `git` (which it can do
automatically for you with a `git` url, more on that in a second):

    $ ln -s ~/Dropbox/dotfiles ~/.homesick/repos

Perform the symlinking:

    $ homesick symlink dotfiles

I have them on Github for easy sharing with others, you can install them via
`homesick` with the command:

    $ homesick clone sirupsen/dotfiles
    $ homesick symlink sirupsen/dotfiles

[homesick]: http://github.com/technicalpickles/homesick

# Screenshots

Clean iTerm 2 in `vim`:

![](http://f.cl.ly/items/1o1M3j3i062B2v2S111N/Screen%20Shot%202011-10-23%20at%206.15.13%20PM.png)

Tabbed iTerm 2 showing a blank `bash` session:

![](http://f.cl.ly/items/3C40001M0I2f0g1U3x3m/Screen%20Shot%202011-10-23%20at%206.16.11%20PM.png)

`tmux` hacking session:

![](http://f.cl.ly/items/1y0h1f3D080E2O423w0k/Screen%20Shot%202011-10-23%20at%206.21.52%20PM.png)
