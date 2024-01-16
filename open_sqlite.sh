#!/bin/bash

open_database() {
    DB_PATH=`lsof -Fn -p $PID| grep "\.sqlite$" | head -n 1`
    PREFIX="n/Users/schaetzs/Dev/moodtag"
    echo $DB_PATH
    DB_PATH=${DB_PATH#"$PREFIX"}
    echo $DB_PATH
    open "${DB_PATH:1}"
}

PID=`pgrep $1` # Pass name of the Xcode project as first argument

if [ -z "$1" ]
then
    echo "Are you sure you have your app opened on a simulator? 🤔";
else
    open_database $PID
fi