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
    <td>Retina Macbook 13"</td>
    <td>Terminal</td>
    <td>bash</td>
    <td>vim</td>
    <td>git</td>
    <td>tmux</td>
    <td><a href="http://www.levien.com/type/myfonts/inconsolata.html">Inconsolata</a> 14pt</td>
  </tr>
</table>

# Installing

I use `linker.sh` to clone and symlink my dotfiles across machines. Invoke it to
symlink the dotfiles. It will prompt to override if the files already exist. Run
`:NeoBundleInstall` in Vim to clone down my Vim plugins.

# Screenshots

Clean iTerm 2 in `vim`:

![](http://i.imgur.com/dCCtqGy.png)

Blank `bash`, only shows current dir, about as complicated the prompt gets.

![](http://i.imgur.com/yLrooPJ.png)

iTerm 2 fullscreen `tmux` hacking session:

![](http://i.imgur.com/Xfr6tbI.png)
