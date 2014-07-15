function _virtualenv_prompt_info() {
  [[ -n $(whence virtualenv_prompt_info) ]] && virtualenv_prompt_info
}

# get the name of the branch we are on
function _git_prompt_info() {
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(_git_remote_status)$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

# get the difference between the local and remote branches
function _git_remote_status() {
  remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
  if [[ -n ${remote} ]]; then
    ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l | tr -d ' ')

    if [[ $behind -gt 0 ]]; then
      echo -n "$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_PREFIX$behind$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_SUFFIX"
    fi
    if [[ $ahead -gt 0 ]]; then
      echo -n "$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_PREFIX$ahead$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_SUFFIX"
    fi
  fi
}

function _git_prompt_count() {
  count=$(command git status --porcelain -b 2> /dev/null | egrep $1 | wc -l | tr -d ' ')
  echo $count
}

function _git_prompt_added() {
  VALUE=$(_git_prompt_count '^A\s+')
  if [[ $VALUE -gt 0 ]]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_ADDED_PREFIX$VALUE$ZSH_THEME_GIT_PROMPT_ADDED_SUFFIX"
    PAREN=1
  fi
}

function _git_prompt_deleted() {
  VALUE=$(_git_prompt_count '(^(\s+|A)?D\s+)')
  if [[ $VALUE -gt 0 ]]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_DELETED_PREFIX$VALUE$ZSH_THEME_GIT_PROMPT_DELETED_SUFFIX"
    PAREN=1
  fi
}

function _git_prompt_conflict() {
  # Technically unmerged status
  VALUE=$(_git_prompt_count '(^UU\s+)')
  if [[ $VALUE -gt 0 ]]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_CONFLICT_PREFIX$VALUE$ZSH_THEME_GIT_PROMPT_CONFLICT_SUFFIX"
    PAREN=1
  fi
}

function _git_prompt_modified() {
  VALUE=$(_git_prompt_count '(^(\s+|A)?M\s+)')
  if [[ $VALUE -gt 0 ]]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_MODIFIED_PREFIX$VALUE$ZSH_THEME_GIT_PROMPT_MODIFIED_SUFFIX"
    PAREN=1
  fi
}

function _git_prompt_renamed() {
  VALUE=$(_git_prompt_count '^R\s+')
  if [[ $VALUE -gt 0 ]]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_RENAMED_PREFIX$VALUE$ZSH_THEME_GIT_PROMPT_RENAMED_SUFFIX"
    PAREN=1
  fi
}

function _git_prompt_untracked() {
  VALUE=$(_git_prompt_count '^\?\?\s+')
  if [[ $VALUE -gt 0 ]]; then
    echo -n "$ZSH_THEME_GIT_PROMPT_UNTRACKED_PREFIX$VALUE$ZSH_THEME_GIT_PROMPT_UNTRACKED_SUFFIX"
    PAREN=1
  fi
}


function _git_prompt_status() {
  PAREN=0
  _git_prompt_added
  _git_prompt_deleted
  _git_prompt_conflict
  _git_prompt_modified
  _git_prompt_renamed
  if [[ ! "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
    _git_prompt_untracked
  fi
  if [[ $PAREN -gt 0 ]]; then
    echo -n ")"
  fi
}

ZSH_THEME_GIT_PROMPT_PREFIX=" (%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}|"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}|%{$fg[green]%}✔%{$reset_color%})"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_PREFIX="↑·"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_SUFFIX=""
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_PREFIX="%{$reset_color%} ↓·"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_SUFFIX=""
ZSH_THEME_GIT_PROMPT_ADDED_PREFIX="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_ADDED_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DELETED_PREFIX="%{$fg[red]%}✕ "
ZSH_THEME_GIT_PROMPT_DELETED_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CONFLICT_PREFIX="%{$fg[red]%}☢ "
ZSH_THEME_GIT_PROMPT_CONFLICT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED_PREFIX="%{$fg[magenta]%}△ "
ZSH_THEME_GIT_PROMPT_MODIFIED_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_RENAMED_PREFIX="%{$fg[yellow]%}➜ "
ZSH_THEME_GIT_PROMPT_RENAMED_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED_PREFIX="…"
ZSH_THEME_GIT_PROMPT_UNTRACKED_SUFFIX=""

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[cyan]%}("
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX=")%{$reset_color%}"

PROMPT='$(_virtualenv_prompt_info)[%n@%m %c]$(_git_prompt_info)$(_git_prompt_status)$ '
#PROMPT='$(_virtualenv_prompt_info)[%n@%m %c]$ '
#RPROMPT='$(_git_prompt_info)$(_git_prompt_status)'