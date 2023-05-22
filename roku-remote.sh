#!/bin/bash
# Interactive terminal IP remote for Roku TVs.
# Depends: bash curl grep
# Use bash 4.4+ for best performance

# TODO:
# add utf8 to keyboard? need some depend for proper url encoding
# ^ could improve search interface. could also add search operators, voice search (triggered by search keypress which isn't used right now)
# backspace/esc key??? can use esc with escape character but then it gets triggered by mistake a lot

###### CONFIG: ######
roku='192.168.0.12' # also settable as sole arg or by pressing 'a'
debug=false         # currently just controls if echo is on
#####################

bash44=false
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

noEcho () {  
  if [[ $debug = false ]]; then
    stty -echo
  fi
}

debug () {
  if [[ $debug = false ]]; then
    debug=true
    stty echo
  else
    debug=false
    stty -echo
  fi
}

# prints control info
controls () {
  F='\033[4m\033[1m' # bold, underline
  B='\033[1m' # bold
  FF='\033[0m' # clear
  
  echo -ne $B"arrows"$FF":arrows  "
  echo -ne $B"\`"$FF":back  "
  echo -ne $B"enter"$FF":OK-enter  "
  echo -ne $B"del"$FF":backspace  "
  echo -ne $B"space"$FF":play-pause  "
  echo -ne $B","$FF":rewind  "
  echo -ne $B"."$FF":forward  "
  echo -ne $B"-"$FF":vol-down  "
  echo -ne $B"="$FF":vol-up  "
  echo -ne $B"["$FF":channel-down  "
  echo -ne $B"]"$FF":channel-up  "
  echo
  echo -ne $F"a"$FF"ddress  "
  echo -ne $F"d"$FF"ebug  "
  echo -ne $F"f"$FF"ind-remote  "
  echo -ne $F"h"$FF"ome  "
  echo -ne $F"i"$FF"nfo-*  "
  echo -ne $F"k"$FF"eyboard-mode  "
  echo -ne $F"m"$FF"ute  "
  echo -ne $F"o"$FF"ff  " 
  echo -ne $F"O"$FF"n  "
  echo -ne $F"p"$FF"ower  "
  echo -ne $F"r"$FF"eplay  "
  echo -ne $F"s"$FF"earch  "
  echo -ne $F"S"$FF"earch-inline  "
  echo -ne $F"y"$FF"outube  "
  echo
  echo -ne $B"0"$FF":tuner  "
  echo -ne "HDMI"$F"1"$FF"  "
  echo -ne "HDMI"$F"2"$FF"  "
  echo -ne "HDMI"$F"3"$FF"  "
  echo -ne "HDMI"$F"4"$FF"  "
  echo -ne $B"5"$FF":AV-in"
  echo
}

# seamless search
# no punctuation support
search () {
  stty echo
  read -ep 'search term: '
  term=${REPLY//' '/'+'}
  curl -gd '' "$roku:8060/search/browse?keyword=$term"
  noEcho
}

# set IP interactively
setIP () {
  stty echo
  read -ep 'new IP: '
  roku=$REPLY
  echo "now controlling $roku"
  noEcho
}

# handle onscreen keyboard events
kb () {
  echo 'entering keyboard mode; Ins to quit'
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
      '[2~') # this isn't working consistently
        echo 'exiting keyboard mode' 
        return 0
      ;;
      *) key='' ;;
    esac
    
    if [[ $key != "" ]]; then
      curl -gd '' "$roku:8060/keypress/$key"
    fi
  done
}

#### main ####
roku=${1:-$roku} # set IP to first arg or fallback to config if no args
echo '* Roku remote *'
echo "controlling $roku"
echo 'c for full control list'
noEcho # turn tty echo off if debug=false

if [ ${BASH_VERSION:0:1} -ge 4 ] && [ ${BASH_VERSION:2:1} -ge 4 ]; then
  bash44=true
fi 

while :; do
  getKey
  
  # change key to roku keypress string to print, or do task and set to 
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
    'O') key='powerOn' ;;
    'p') key='power' ;;
    ']') key='channelUp' ;;
    '[') key='channelDown' ;;
    '0') key='inputTuner' ;;
    '1') key='inputHDMI1' ;;
    '2') key='inputHDMI2' ;;
    '3') key='inputHDMI3' ;;
    '4') key='inputHDMI4' ;;
    '5') key='inputAV1' ;;
    '`') key='back' ;;
    '[A') key='up' ;;
    '[B') key='down' ;;
    '[D') key='left' ;;
    '[C') key='right' ;;
    'k') kb; key='' ;;
    's') curl -d '' "$roku:8060/search/browse?keyword="; key='' ;; # go to search
    'S') search; key='' ;;
    'a') setIP; key='' ;;
    'y') curl -d '' "$roku:8060/launch/837"; key='' ;; # youtube
    'd') debug; key='' ;;
    'c') controls; key='' ;;
    *) key='' ;;
  esac
  if [[ -n $key ]]; then 
    curl -gd '' "$roku:8060/keypress/$key" 
  fi
done