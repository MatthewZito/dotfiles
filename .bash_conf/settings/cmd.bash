# generate base64
base64 () {
  openssl base64<<<"$1"
}

# render a markdown file
rmd () {
  pandoc "$1" | lynx -stdin
}

# add a new alias to bash rc
# add_alias name "cmd && cmd -flag && cmd"
add_alias () {
  local alias_name="$1"

  shift

  local alias_body="$@"

  [[ -z "$alias_name" ]] && {
    echo "[-] Alias name not provided"
    return 1
  }

  [[ -z "$alias_body" ]] && {
    echo "[-] Alias body not provided"
    return 1
  }

  echo "alias $alias_name='$alias_body'" >> "$HOME/.bash_conf/settings/alias.bash"

  (( "$?" == 0 )) && echo "[+] Successfully added new alias"
}

# less running processes of target
psaux () {
  pgrep -f "$@" | xargs ps -fp 2>/dev/null
}

# mount encrypted dir
open_enc () {
  local mount="$1" proxy="$2"
  
  encfs ${mount:-~/.enc/} ${proxy:-~/enc/}
}

# unmount encrypted dir
close_enc () {
  local proxy="$1"

  fusermount -u ${proxy:-~/enc}
}

# make window transparent
make_transparent () {
  xprop -format _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xEFFFFFFF
}

# connect bluetooth device
blue_conn () {
  local default='DC:D3:A2:C9:23:7C'

  sudo bluetoothctl connect "${1:-$default}"
}

# launch a dockerized dev environment of pwd
dockerize () {
  docker_dir="$HOME/.bash_conf/docker/"
  docker_tag='goldmund:dev'

  is_dev_extant="$(docker image ls -f reference=$docker_tag | awk '{ print $1":"$2 }' | grep $docker_tag)"

  if [[ "$is_dev_extant" != "$docker_tag" ]]; then
    echo -e "[!] Containerized dev environment not extant; creating image...\n"
    docker build -f "$docker_dir/Dockerfile" -t "$docker_tag" .

    if [[ $? -eq 0 ]]; then
      echo -e "[+] Image created\n"
    else 
      echo "[-] Failed; code $?"
    fi
  fi

  if [[ "$is_dev_extant" == "$docker_tag"  ]]; then
    echo -e "Building $docker_tag as an ephemeral dev env in $(pwd)...\n"
    docker run --rm -it -v "$(pwd):/ephemeral" "$docker_tag"
  fi
}

# initialize a new npm pkg project
npm_bootstrap () {
  local script_loc="$HOME/.bash_conf/scripts/npm_bootstrap.bash"

  bash $script_loc
}

# set current branch to track remote (default: 'origin')
gtrack () {
  local remote="$1"

  git branch -u "${remote:-origin}/$(git rev-parse --abbrev-ref HEAD)"
}