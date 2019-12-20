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

    local editor='vim'
    if [ "$(command -v $FO_SET_EDITOR)" = "" ]; then
      # Asks user to use default editor.
      printf "Use default editor? [y/n]: " 
      read use_default
      if [[ ! ${use_default} =~ ^[y,n]$ ]];then
        echo 'Only y/n is allowed. Using default editor.'
        use_default='y'
      fi

      if [[ "$use_default" == "n" ]];then
        printf "Enter your editor (if not valid, default will be used): " 
        read editor
        if [ "$(command -v $editor)" = "" ];then
          editor='vim'
          echo "No such editor, using default $editor instead."
        fi
      fi

      export FO_SET_EDITOR="$editor"
      export EDITOR="$FO_SET_EDITOR"
    fi

    local out filepath input ext
    input="fd . $HOME -H "
    IFS=$'\n' 
    out=($(eval $input | fzf --preview-window down:10 --preview='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat{}) 2> /dev/null | head -200' --exit-0))
    filepath="$(head -2 <<< "$out" | tail -1)"
    ext="${filepath##*.}"

    # Enter directory
    if [ -d "$filepath" ];then
      cd "$filepath"
      return
    fi

    # All else must be a file to continue.
    if [ ! -f "$filepath" ];then
      return
    fi

    if [[ $(file -b "$filepath") =~ (JPEG|PDF|PNG|JPEG|GIF) ]];then
        open "$filepath"
    else
      # Exclude all executables except .sh or .zsh files for now.
      if [ -x "$filepath" ] && ([ $ext != "sh" ] && [ $ext != "zsh" ]);then
        echo "$filepath is an executable."
        return
      fi
      ${EDITOR:-vim} "$filepath"
    fi
}

# First time sourcing this file remove existing env var.
unset FO_SET_EDITOR
