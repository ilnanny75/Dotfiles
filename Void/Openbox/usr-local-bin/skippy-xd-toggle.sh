#!/bin/sh
#================================================
#   O.S.      : Void Linux
#   Author    : Cristian Pozzessere = ilnanny75
#   Github    : https://github.com/ilnanny75
#================================================
killSkippyXd() {

  killall 'skippy-xd'

  if [ -f '/tmp/skippy-xd-fifo' ]
  then
    rm /tmp/skippy-xd-fifo
    touch /tmp/skippy-xd-fifo
  fi

  exit $?

}

toggleSkippyXd() {

  skippyDaemonStartCommand="skippy-xd --start-daemon"
  psSkippyOut="`pgrep -f 'skippy-xd '`"
  psSkippyActivateOut="`pgrep -f 'skippy-xd --activate-window-picker'`"
  psSkippyToggleOut="`pgrep -f 'skippy-xd --toggle-window-picker'`"

  skippyConfig="$1"

  if [ -f "$skippyConfig" ]
  then
    skippyDaemonStartCommand="$skippyDaemonStartCommand --config $skippyConfig"
  fi

# # Se,quando chiami skippy-xd, per avviare il selettore di finestre, 
  ## esiste già un processo per farlo, quindi skippy-xd è bloccato, 
  ## quindi dobbiamo cancellare la sua coda e riavviare il suo demone.
  ## ALTRIMENTI, se il demone skippy-xd non è stato avviato,
  ## dovremmo avviarlo.
  if [ ! -z "$psSkippyActivateOut" ] || [ ! -z "$psSkippyToggleOut" ]
  then
    killSkippyXd
    $skippyDaemonStartCommand &
  elif [ -z "$psSkippyOut" ]
  then
    $skippyDaemonStartCommand &
  fi

  skippy-xd --toggle-window-picker

  exit $?

}

(toggleSkippyXd "$@")
