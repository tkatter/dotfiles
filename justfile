set shell := ['bash', '-uc', '--']

root_dir   := justfile_directory()
cache_dir  := cache_dir()
config_dir := config_dir()
data_dir   := data_dir()
home_dir   := home_dir()

pkgs_log := root_dir / 'installed-pkgs.txt'

default:
  @just --list

[doc("add a path to gitignore")]
ignore path: (add-date root_dir / '.gitignore')
  echo "{{path}}" >> {{root_dir / '.gitignore'}}

[doc("update the list of installed packages with 'pacman -Q'")]
update-pkg-list: (add-date pkgs_log 'o')
  #!/usr/bin/env bash
  (
    echo
    echo '###########################'
    echo '##                       ##'
    echo '##         CARGO         ##'
    echo '##                       ##'
    echo '###########################'
    echo
    cargo install --list
    echo
    echo '############################'
    echo '##                        ##'
    echo '##  EXPLICITLY INSTALLED  ##'
    echo '##                        ##'
    echo '############################'
    echo
    pacman -Qe
    echo
    echo '############################'
    echo '##                        ##'
    echo '##     INSTALLED DEPS     ##'
    echo '##                        ##'
    echo '############################'
    echo
    pacman -Qd
  )>> "{{pkgs_log}}"

# install XDG dirs
[private]
@dirs:
  install -d {{cache_dir}}
  install -d {{config_dir}}
  install -d {{data_dir}}

[private]
[arg('mode', pattern='a|o')]
add-date path mode='a':
  #!/usr/bin/env bash
  case '{{mode}}' in
    a) echo '# {{datetime("%c")}}' >> {{path}} ;;
    o) echo '# {{datetime("%c")}}' > {{path}} ;;
  esac

hash:
  ./dir-hasher/zig-out/bin/dir_hasher -d ~/.config -i .current-hash | b3sum | awk '{print $1}'

check-hash:
  #!/usr/bin/env bash
  current_hash="$(< .current-hash)"
  this_hash="$(just hash 2>/dev/null)"
  if [[ "$current_hash" != "$this_hash" ]]; then
    echo "hashes do not match... saving new hash" >&2
    echo "$this_hash" > .current-hash
    exit 1
  fi
