# Piano assistant

## Installation :

This project uses rp (Redis Pipe) which needs go.

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

## How to use

Just do `./run.sh`

At this time, it will just "listen" to what is played on the piano/midi instrument, try to guess what chords are played and display them.
