#!/bin/bash

COMMAND=$1
WORKDIR=/root/.vpn

function connect () {
  SERVER=$1
  SERVER_DIR=$(pwd)/.vpn/configs/$SERVER
  if [ -d $SERVER_DIR ]
  then
    echo Connecting to $SERVER
    CONFIG=$SERVER_DIR/config.ovpn
    AUTH=$SERVER_DIR/auth
    openvpn --config $CONFIG --auth-user-pass $AUTH
  else
    echo Server does not exsist
  fi
}

function new () {
  CONFIG=$1
  NAME=$2
  USAGE="USAGE: vpn new [CONFIG-FILE.ovp] [NAME]"

  if [ ! -r $CONFIG ]
  then
    echo $USAGE
    echo Config file not specified"!"
    exit
  fi

  if [ -z $NAME ]
  then
    FILENAME="$(basename -- $CONFIG)"
    NAME="${FILENAME%.*}"
  fi

  WORKDIR=$(pwd)/.vpn/configs/$NAME
  if [ -d $WORKDIR ]
  then
    echo Server $NAME already exists"!"
    exit
  fi

  echo Creating new server with:
  echo -e " Config: \t$CONFIG"
  echo -e " Name: \t\t$NAME"

  mkdir $WORKDIR

  cp $CONFIG $WORKDIR/config.ovpn

  read -p "Username: " USERNAME
  read -sp "Password: " PASSWORD
  echo

  echo $USERNAME > $WORKDIR/auth
  echo $PASSWORD >> $WORKDIR/auth

}

function remove () {
  SERVER=$1
  WORKDIR=$(pwd)/.vpn/configs/$SERVER
  rm -r $WORKDIR
  echo Removed $SERVER
}

case "${COMMAND}" in
"connect") connect $2;;
"new") new $2 $3;;
"remove") remove $2;;
esac

#SERVER=$1
#WORKDIR="/root/.vpn/configs/$SERVER/"

#openvpn --config $WORKDIR/client.ovpn --auth-user-pass $WORKDIR/auth
