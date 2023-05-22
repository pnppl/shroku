#!/bin/bash
# Interactive terminal IP remote for Roku TVs.
# Depends: bash curl
# Use bash 4.4+ for best performance

# TODO:
# power toggle
# add utf8 to keyboard? need some depend for proper url encoding
# ^ could improve search interface. could also add search operators, voice search (triggered by search keypress which isn't used right now)
# improve behavior when holding key down/clean up terminal printing
# backspace/esc key??? can use esc with escape character but then it gets triggered by mistake a lot
# set IP with arg or interactively

### CONFIG: ###
roku='192.168.0.8' # 8 in bedroom, 12 in living room
bash44=true
###############

key='NULL'
escape=$(printf "\u1b")

# handle character input
getKey () {
  # read one char
  read -rsn1
  key=$REPLY
  
  # get arrows etc
  if [[ $REPLY == $escape ]] && [[ $bash44 = true ]]; then
    if [[ $bash44 = true ]]; then
      read -rsn3 -t 0.1
      if [[ $REPLY != "[A" ]] && [[ $REPLY != "[B" ]] && [[ $REPLY != "[C" ]] \
      && [[ $REPLY != "[D" ]] && [[ $REPLY != "[2~" ]] && [[ $REPLY != "[3~" ]]; then
        REPLY=$escape # must be the esc or bs key if we only get an escape
      fi
    elif [[ $REPLY == $escape ]]; then
      read -rsn3 -t 1
    fi
  fi
}

# seamless search
# no punctuation support currently
search () {
  read -ep 'search term: '
  term=${REPLY//' '/'+'}
  curl -gd '' "$roku:8060/search/browse?keyword=$term"
}

# handle onscreen keyboard
kb () {
  echo 'entering onscreen keyboard mode; Ins to quit'
  while :; do
    getKey
    # change key to roku keypress string (or my control code)
    case $REPLY in
      '!' | '"' |  "'" | '(' | ')' | '*' | '-' | '.' \
      | '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '<' | '>' \
      | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' \
      | 'P' | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z' | '[' | ']' | '^' | '_' \
      | '`' | 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' | 'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' \
      | 'p' | 'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z' | '{' | '}' | '~')
        key="Lit_$REPLY" ;; # api docs lied
      '') key='enter' ;;
      ' ') key='Lit_+' ;;
      '@') key='Lit_%40' ;;
      '#') key='Lit_%23' ;;
      '$') key='Lit_%24' ;;
      '%') key='Lit_%25' ;;
      '&') key='Lit_%26' ;;
      '=') key='Lit_%3D' ;;
      '+') key='Lit_%2B' ;;
      '\') key='Lit_%5C' ;;
      '|') key='Lit_%7C' ;;
      ';') key='Lit_%3B' ;;
      ':') key='Lit_%3A' ;;
      '?') key='Lit_%3F' ;;
      '/') key='Lit_%2F' ;;
      ',') key='Lit_%2C' ;;
      '[A') key='up' ;;
      '[B') key='down' ;;
      '[D') key='left' ;;
      '[C') key='right' ;;
      '`')  key='back' ;;
      '[3~') key='backspace' ;; # Del key
      '[2~') 
        echo 'exiting onscreen keyboard mode' 
        return 0
      ;;
      *) key='NULL' ;;
    esac
    
    if [[ $key != "NULL" ]]; then
      curl -gd '' "$roku:8060/keypress/$key"
    fi
  done
}

#### main ####
echo '* Roku remote *'
echo "controlling $roku"
echo '(controls here)'
while :; do
  getKey
  
  # change key to roku keypress string (or my control code)
  case $REPLY in
    'h') key='home' ;;
    ',') key='rev' ;;
    '.') key='fwd' ;;
    ' ') key='play' ;;
    '')  key='select' ;; # Enter key
    'r') key='instantReplay' ;;
    'i') key='info' ;;
    'f') key='findRemote' ;;
    '-') key='volumeDown' ;;
    '=') key='volumeUp' ;;
    'm') key='volumeMute' ;;
    'o') key='powerOff' ;;
    'O') key='powerOn' ;; # make into toggle with /query/device-info
    ']') key='channelUp' ;;
    '[') key='channelDown' ;;
    '0') key='inputTuner' ;;
    '1') key='inputHDMI1' ;;
    '2') key='inputHDMI2' ;;
    '3') key='inputHDMI3' ;;
    '4') key='inputHDMI4' ;;
    '5') key='inputAV1' ;;
    '[A') key='up' ;;
    '[B') key='down' ;;
    '[D') key='left' ;;
    '[C') key='right' ;;
    '`') key='back' ;;
    'k') key='ONSCREEN_KB' ;;
#   'o') key='POWER';;
    's') key='SEARCH' ;;
    'S') key='SEARCH_SEAMLESS' ;;
    *) key='NULL' ;;
  esac
    
# send keypresses
  case $key in
    'ONSCREEN_KB') kb ;;
    'POWER') ;; # implement
    'SEARCH') curl -gd '' "$roku:8060/search/browse?keyword=" ;;
    'SEARCH_SEAMLESS') search ;;
    'NULL') ;;
    *) curl -gd '' "$roku:8060/keypress/$key" ;;
  esac
done