# zrm

`zrm` is a command line tool written in __Nim__ that uses `fzf` (_Fuzzy Finder_) to allow the deletion of folders and files in a simple and efficient way.

With `zrm`, you can browse through your files and directories using an interactive interface and select multiple items for deletion by simply pressing the __TAB__ key. This functionality makes deleting files and folders faster and more convenient than traditional methods.

## Build

## 1) Install Nim

[Nim](https://nim-lang.org/) is a statically typed compiled systems programming language. It combines successful concepts from mature languages like Python, Ada and Modula.

### 2) Clone the repository

```sh
git clone https://github.com/gabrielcapilla/zrm.git
```

### 3) Change dir to `zrm`

```sh
cd zrm
```

### 4) Build program with `nimble`

```sh
nimble --verbose -d:release --opt:speed build
```

### 4 ) Install with `nimble`

```sh
nimble install
```

## Uninstall

Uninstall `zrm` just typing

```sh
nimble uninstall zrm
```
