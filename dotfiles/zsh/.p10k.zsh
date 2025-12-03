# Minimal, fast, popular Powerlevel10k config for zsh.
# Based on the "lean" preset with gitstatus enabled.

# Speed: enable instant prompt early (Powerlevel10k handles safety).
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# Reset prior values so re-sourcing works.
unset -m 'POWERLEVEL9K_*|POWERLEVEL10K_*|DEFAULT_USER'

# Core look
typeset -g POWERLEVEL9K_MODE=nerdfont-complete
typeset -g POWERLEVEL9K_ICON_PADDING=none
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=' ' POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' ' POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '

# Prompt char styling
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='Ⅴ'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=70
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196

# Directory: short, with truncate-to-root.
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v2
typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=true
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER='…'
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_first_and_last
typeset -g POWERLEVEL9K_DIR_FOREGROUND=110

# Git: keep fast gitstatus with familiar icons.
typeset -g POWERLEVEL10K_DISABLE_GITSTATUS=false
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=''
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
typeset -g POWERLEVEL9K_VCS_FOREGROUND=39
typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes git-untracked git-aheadbehind git-stash git-remotebranch git-tag)

# Status / timing
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=1500
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=178
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=39
typeset -g POWERLEVEL9K_TIME_FORMAT='%H:%M'
typeset -g POWERLEVEL9K_TIME_FOREGROUND=244

# Transient prompt (keeps history compact).
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

# Apply configuration.
(( ! $+functions[p10k] )) || p10k reload
