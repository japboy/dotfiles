dotfiles
========

Yet another dotfiles written by [@japboy](http://github.com/japboy/).

**Heavily work in progress, and this is currently focusing only on macOS**

Installation
------------

To install or update, simply copy and paste the command below:

```bash
bash <(curl -L https://raw.github.com/japboy/dotfiles/master/bootstrap.sh)
```

You can also install/update without Git by downloading the repository and put it
in `~/.dotfiles` then;

```bash
bash ~/.dotfiles/bootstrap.sh sync
```

```cmd
powershell ^
    -ExecutionPolicy RemoteSigned ^
    -Command "$cwd = Get-Location; Start-Process powershell -ArgumentList \"-ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command Push-Location -Path $cwd; $(Join-Path $cwd bootstrap.ps1)\" -Verb RunAs"
```


### .shell_extras

You can create an addtional file named `.shell_extras` in your home directory. It
will be loaded if there. This is intend to be used for some credentials like
secret tokens etc.

`.shell_extras` should be something like this:

```bash
#
# EXTRAS


##
# Amazon EC2 API Tools

export AWS_ACCESS_KEY='XXXXXXXXXXXXXXXXXXXX'
export AWS_SECRET_KEY='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'


##
# gisty

export GISTY_ACCESS_TOKEN='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

Requirements
------------

### macOS

* macOS Ventura 13.6.3
* [Xcode](http://itunes.apple.com/en/app/xcode/id497799835)
* [Command Line Tools](http://developer.apple.com/xcode/) (if you prefer to not installing entire Xcode SDK)

### Linux

* Meh X(

Credits
-------

* [GitHub does dotfiles - dotfiles.github.io](http://dotfiles.github.io/)
* [altercation/solarized · GitHub](https://github.com/altercation/solarized)
* [github/gitignore · GitHub](https://github.com/github/gitignore)
* [seebi/dircolors-solarized · GitHub](https://github.com/seebi/dircolors-solarized)

License
-------

Distributed under the [Unlicense](http://unlicense.org/).
