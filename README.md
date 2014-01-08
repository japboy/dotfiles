dotfiles
========

Yet another dotfiles written by [@japboy](http://github.com/japboy/).

**Heavily work in progress, and this is currently focusing only on Mac OS X**

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

### .bash_extras

You can create an addtional file named `.bash_extras` in your home directory. It
will be loaded if there. This is intend to be used for some credentials like
secret tokens etc.

`.bash_extras` should be something like this:

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

### Mac OS X

* Mac OS X 10.9 (Mavericks)
* [Xcode](http://itunes.apple.com/en/app/xcode/id497799835)
* [Command Line Tools](http://developer.apple.com/xcode/) (if you prefer to not installing entire Xcode SDK)

### Linux

* Maybe for Ubuntu 12.04

Credits
-------

* [GitHub does dotfiles - dotfiles.github.io](http://dotfiles.github.io/)
* [altercation/solarized · GitHub](https://github.com/altercation/solarized)
* [github/gitignore · GitHub](https://github.com/github/gitignore)
* [seebi/dircolors-solarized · GitHub](https://github.com/seebi/dircolors-solarized)

License
-------

Distributed under the [Unlicense](http://unlicense.org/).
