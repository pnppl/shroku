# Interactive terminal IP remote for Roku TVs
Depends: bash curl grep

Use bash 4.4+ for best performance

### Usage:
You can supply the IP address of your Roku as an argument to the script, by editing the script, or by pressing 'a' while the script is running and not in keyboard mode.

By default the script is in normal/remote mode. Pressing 'k' puts the script in keyboard mode. In this mode, printable ASCII characters can be typed into the Roku and most of the controls listed below will not work until you exit keyboard mode.

### Controls:
**arrows**: arrows

**`**: back

**enter**: OK-enter

**delete**: backspace (keyboard mode)

**space**: play-pause

**,**: rewind

**.**: forward

**-**: vol-down

**=**: vol-up

**[**: channel-down

**]**: channel-up

**a**ddress

show-**c**ontrols

**d**ebug

**f**ind-remote

**h**ome

**i**nfo-*

**k**eyboard-mode

**m**ute

**o**ff

**O**n

**p**ower

**r**eplay

**s**earch

**S**earch-inline

**y**outube

**0**: tuner

HDMI**1**

HDMI**2**

HDMI**3**

HDMI**4**

**5**: AV-in

### Refs:

[Roku API docs](https://sdkdocs-archive.roku.com/External-Control-API_1611563.html)

[RoseSecurity/Abusing-Roku-APIs (incl. info on locating IP)](https://github.com/RoseSecurity/Abusing-Roku-APIs)

[Bash's read builtin trickiness](https://stackoverflow.com/a/44748333)
