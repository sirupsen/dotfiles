# Sirupsen's Dotfiles

Dotfiles I have used and tweaked for the past couple of years. They're simple
and optimized for a 13" laptop.

They go hand in hand with my [`babushka`
deps](https://github.com/sirupsen/babushka-deps) which provision my development
machine.

# Setup

<table>
  <tr>
    <th>Hardware</th>
    <th>Terminal</th>
    <th>Shell</th>
    <th>Editor</th>
    <th>Version control</th>
    <th>Multiplexer</th>
    <th>Font</th>
  </tr>
  <tr>
    <td>Retina Macbook 13", OS X</td>
    <td>iTerm 2</td>
    <td>bash</td>
    <td>vim</td>
    <td>git</td>
    <td>tmux</td>
    <td><a href="http://www.levien.com/type/myfonts/inconsolata.html">Inconsolata</a> 14pt</td>
  </tr>
</table>

# Installing

I use [homesick][homesick] to clone and symlink my dotfiles across machines.
It's as easy as:

```bash
$ gem install homesick
$ homesick clone Sirupsen/dotfiles
$ homesick symlink Sirupsen/dotfiles
```

[homesick]: http://github.com/technicalpickles/homesick

# Screenshots

Clean iTerm 2 in `vim`:

![](http://i.imgur.com/dCCtqGy.png)

Blank `bash`, only shows current dir, about as complicated the prompt gets.

![](http://i.imgur.com/yLrooPJ.png)

iTerm 2 fullscreen `tmux` hacking session:

![](http://i.imgur.com/Xfr6tbI.png)
