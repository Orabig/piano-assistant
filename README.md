# Piano assistant

Note : This project is a work in progress. I won't say no to some help. If you're slightly interrested into the project, and even if you don't think having the knowledge needed, you surely are wrong, so don't hesitate to contact me.

## What is it ?

The aim of this project is to have a device which displays piano scores. The main goal I'd want to achieve is to make this recognize what the pianist is playing and thus automatically show the right score.
I have to make some experiment to find what will be the most easy way to use and control the system.

The raspberry uses a ad-hoc hardware electronic device to receive and read MIDI events from the piano.

Eventually, this project could remove the need of an hardware part if the MIDI is not necessary (the software could then be controlled by a keyboard or simple buttons), for example to be used by guitar players.
However, I'm not a good guitarist, thus this is not my main goal.

![image](https://cdn.discordapp.com/attachments/397139717650513921/587754700602998805/jOu4MHlH0hePs_m9KY9_9qSonuESHEyZfbY5RsNqoKaJewHBfqRFp5LNBdItDtIl3x1TNA5T-wVAQ_kYtzd6fusgUZuGBKHywECD.png)

## How to run the software

Just do `sudo ./run.sh`

At this time, the software will "listen" to what is played on the piano/midi device, try to guess what chords are played and send them onto the redis stream. (Actually several redis "streams" are used, and all the components are listening and writing to them to communicate)

All what is played on the piano is also recorded in "record" files. (to end a record and pass to the next one, just tap rapidly twice on the pedal)

To display the main "streams", run `./display.sh` which will show the incoming data realtime :

```
┌─ MIDI EVENTS────────────┐┌─ CHORDS ──────────────────────────────────────────┐
│9 1 82 0                 ││Ab5-                                               │
│9 1 79 50                ││Ab                                                 │
│9 1 55 28                ││Ab                                                 │
│9 1 58 28                ││Ab                                                 │
│9 1 61 30                ││Ab                                                 │
│9 1 64 25                ││Ab                                                 │
│9 1 79 0                 ││Ab                                                 │
│9 1 64 0                 ││Gsus4                                              │
│9 1 55 0                 ││Gsus4                                              │
│9 1 61 0                 ││F7                                                 │
│9 1 58 0                 ││F7                                                 │
│9 1 75 55                ││Amaj7                                              │
│11 1 64 72               ││A                                                  │
│11 1 64 40               ││Abm                                                │
│11 1 64 0                ││Abm                                                │
└─────────────────────────┘│Gm                                                 │
┌─ NOTES ─────────────────┐│Gm7                                                │
│                         ││Gm                                                 │
│82                       ││G                                                  │
│                         ││Gm5-                                               │
│79                       ││Gdim                                               │
│55 79                    ││Gdim                                               │
│58 55 79                 ││Gm5-                                               │
│58 55 61 79              ││                                                   │
│58 55 61 64 79           ││                                                   │
│58 55 61 64              ││                                                   │
│58 55 61                 ││                                                   │
│58 61                    ││                                                   │
│58                       ││                                                   │
│                         ││                                                   │
│75                       ││                                                   │
└─────────────────────────┘└───────────────────────────────────────────────────┘
```

It is possible to "simulate" a piano (for example if you don't have the hardware part yet), by sending "replay" data back into the streams.

`./loop_midi_replay.sh streams/<file>` playbacks the midi events in the replay file. (the events are played at the exact same pace than the original performance)

`./song.pl < scores/my_song.song` is a work-in-progress draft to have some way to encode/decode a piano score, and to display it in a clear and compact way. For now, there is only one song hardcoded.
In the future it would be cool to be able to :
- Translate scores from internet sources (from guitar-pro files for example, or from raw-text resources)
- Directly enter and edit scores by using the piano keyboard and MIDI interface

## Installation :

This project uses rp (Redis Pipe) which is a useful tool that can read/write on redis through bash pipes. It also needs go to be installed.

### Install Go and rp

```
wget -q https://dl.google.com/go/go1.12.5.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.12.5.linux-armv6l.tar.gz
rm go1.12.5.linux-armv6l.tar.gz
```

Add :
```
export PATH=$PATH:/usr/local/go/bin
```
at the end of /etc/profile

Add :
```
export GOPATH=$HOME/go
export PATH=$PATH:/home/pi/go/bin
```
at the end of /home/pi/.profile


then :
```
go get github.com/whee/rp/cmd/rp
```

### Install redis

sudo apt-get install redis-server

## Hardware

A MIDI input interface should be plugged on the RX GPIO pin

(TODO : add here schematics and details about the PCB)



# Protocols

Redis serves as a data bus, that handles streams of events between micro-components.

Each stream should be prefixed by a trigram and a timestamp

NOT 123456.1 ...
CHD 123456.2 ...
...
