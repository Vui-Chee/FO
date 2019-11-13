function fo() {
    # Tested on OSX only.
    [ `uname -s` != 'Darwin' ] && return

    # Install brew
    if [ ! -x "$(which brew)" ];then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Install fzf 
    [ ! -x "$(which fzf)" ] && brew install fzf
    # Install fd
    [ ! -x "$(which fd)" ] && brew install fd
    # Install bat
    [ ! -x "$(which bat)" ] && brew install bat

    local out filepath key input
    local lastArg="${@: -1}"
    input='fd . '$lastArg' -H '
    IFS=$'\n' 
    out=($(eval $input | fzf --preview-window down:10 --preview='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat{}) 2> /dev/null | head -200' --exit-0))
    filepath=$(head -2 <<< "$out" | tail -1)

    local ext="${filepath##*.}" 
    
    if [ -d "$filepath" ];then
        if [ "$ext" = "app" ];then
            open "$filepath"
        else
            cd "$filepath"
        fi
    fi

    if [ -f "$filepath" ] && [ ! -x "$filepath" ];then
      if [[ $(file -b "$filepath") =~ (JPEG|PDF|PNG|JPEG|GIF) ]];then
          open "$filepath"
      else
          # Use your favourite editor. (In my case, it's Neovim)
          ${EDITOR:-nvim} "$filepath"
      fi
    fi
}