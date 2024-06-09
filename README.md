# アプリケーションおよび、dotfileを提供
## 概要
各アプリケーションとdotfileをインストーラーとして提供する。\
アプリケーションはビルドインストールで提供する。\
インストール先はローカル(デフォルトは`~/.sys`)を想定するが、引数によって変更は可能。\
dotfileはファイルコピーで提供する。

## アプリケーション
* [xstow](https://github.com/majorkingleo/xstow)(初回のみ)
* [git](https://github.com/git/git)
* [tmux](https://github.com/tmux/tmux)
* [vim](https://github.com/vim/vim)
* [neovim](https://github.com/neovim/neovim)

## dotfiles
* [git](conf/git/README.md)
* [tmux](conf/tmux/README.md)
* [vim](conf/vim/README.md)
* shell
  * [bash](conf/git/README.md)

## 使用方法
ex) アプリケーションインストール(git + tmux)
```bash
$ ./install.sh app --git --tmux
```

ex) アプリケーションバージョン表示(vim + tmux)
```bash
$ ./install.sh show --vim --tmux
```

ex) アプリケーションバージョンの切り替え(git + vim)
```bash
$ ./install.sh switch --git <switch version> --vim <switch version>
```

ex) アプリケーションバージョンの削除(git + neovim)
```bash
$ ./install.sh remove --git <remove version> --neovim <remove version>
```

ex) アプリケーションのdotfileをインストール(git + tmux)
```bash
$ ./install.sh conf --git --tmux
```

ex) dotfileのバックアップを削除(すべて)
```bash
$ ./install.sh clean
```

