# midgard's Theme
# Adapted from the agnoster theme - https://gist.github.com/3712874
#
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

# Add a segment: background colour, foreground colour, and text
prompt_segment() {
  echo -n "%{%K{$1}%}"
  [[ -n $CURRENT_BG ]] && echo -n "%{%F{$CURRENT_BG}%}\u258c%}"
  echo -n "%{%F{$2}%}$3"

  CURRENT_BG=$1
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{%k%F{$CURRENT_BG}%}\u258c"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  unset CURRENT_BG
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local ref dirty mode repo_path

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    # zstyle ':vcs_info:*+*:*' debug true
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' unstagedstr '*'
    zstyle ':vcs_info:*' max-exports 3
    zstyle ':vcs_info:*' actionformats '%b' '%a%c%u' '%m'
    zstyle ':vcs_info:*' formats '⧀ %b' '%c%u' '%m'
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-st

    +vi-git-untracked() {
        if [[ "$1" == "0" ]] && git status --porcelain | grep '??' &> /dev/null ; then
            hook_com[unstaged]+="?"
        fi
    }

    +vi-git-st() {
      if [[ "$1" == "0" ]]; then
        local ahead behind
        local -a gitstatus

        ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
        behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
        remote=`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null`

	# (( $ahead || $behind )) && gitstatus+="${remote%%/*}"
        gitstatus+="${remote%%/*}"
        (( $ahead )) && gitstatus+=( "\u2191${ahead}" )
        (( $behind )) && gitstatus+=( "\u2193${behind}" )

        hook_com[misc]+="${gitstatus}"
      fi
    }

    vcs_info
    prompt_segment blue white "${vcs_info_msg_0_%% }${mode}"
    if [[ -n $vcs_info_msg_1_ ]]; then
        prompt_segment magenta white $vcs_info_msg_1_
    fi
    if [[ -n $vcs_info_msg_2_ ]]; then
        prompt_segment 11 black $vcs_info_msg_2_
    fi
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  [[ $UID -eq 0 ]] && prompt_segment red 226 ""
  [[ $RETVAL -ne 0 ]] && prompt_segment red yellow " $RETVAL"
  [[ $(jobs -l | wc -l) -gt 0 ]] && prompt_segment 17 default "$(jobs -l | wc -l)"
}

print_colors() {
  # Color names 0-7: black red green yellow blue magenta cyan white

  # Loop through background colors
  for bg_color in {0..93}; do
    # Set background color
    echo -n "%{%K{$bg_color}%}$bg_color:"

    # Loop through foreground colors
    for fg_color in {000..015}; do
      # Set foreground color and print color name
      echo -n "%{%F{$fg_color}%} ${fg_color}"
    done

    # Reset colors
    echo "%{%k%}"
  done
}

## Main prompt
build_prompt() {
  RETVAL=$?
  # help with checking color options:
  [[ -n "$PROMPT_COLORRANGE" ]] && print_colors
  prompt_status
  # show the user:
  [[ "$USER" != "$DEFAULT_USER" ]] && prompt_segment 8 white "%n"
  # dir:
  prompt_segment 28 white '%~'
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt)'
