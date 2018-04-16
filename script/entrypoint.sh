#!/bin/bash
imagename="isaac8709/agensgraph"
tag="1.3.0"

mode=$1

usage="Usage: \n"
usage="$usage\t\tExistDB : docker run -it -d -net=host -v [docker volume name]:[full path of $AGDATA] --name agensgraph $imagename:$tag ExistDB\n"
usage="$usage\t\tInitDB : docker run -it -d -net=host -v [docker volume name]:[full path of $AGDATA] -e DB_NAME=[created database name] --name agensgraph $imagename:$tag InitDB\n"
usage="$usage\t\tbash : docker run -it $imagename:$tag bash \n"

function main(){
    case $mode in
    (InitDB)
        if [ "$DB_NAME" ]; then
            runInitDB
            checkProcessStatus
        else
            echo 'AgensGraph Initialize Database ERROR'
            echo -e $usage
            exit 1
        fi
        ;;
    (InitDBForce)
        if [ "$DB_NAME" ]; then
            runInitDBForce
            checkProcessStatus
        else
            echo 'AgensGraph Initialize Database ERROR'
            echo -e $usage
            exit 1
        fi
        ;;        
    (ExistDB)
        runExistDB
        checkProcessStatus
        ;;
    (bash)
        runBash
        ;;
    (*)
        echo $mode
        echo -e $usage
        exit 1
        ;;
    esac

}

function runInitDB(){
    echo "runInitDB Start"
    PROCESS_NAME=postgres

    if [ -d $AG_DATA -a -n "$(ls -A $AG_DATA)" ] ; then
        runExistDB
    else
        mkdir -p $AGDATA

        # set permission 700 for running agensgraph
        chmod 700 $AGDATA

        # run initdb
        initdb -D $AGDATA -E UTF-8

        # starting the server
        ag_ctl start -D $AGDATA
        sleep 10

        # create db
        createdb $DB_NAME -E UTF-8
    fi    
}

function runInitDBForce(){
    echo "runInitDBForce Start"
    PROCESS_NAME=postgres

    # clean data path
    rm -rf $AGDATA

    mkdir -p $AGDATA

    # set permission 700 for running agensgraph
    chmod 700 $AGDATA
    
    # run initdb
    initdb -D $AGDATA -E UTF-8
    
    # starting the server
    ag_ctl start -D $AGDATA
    sleep 10

    # create db
    createdb $DB_NAME -E UTF-8
}

function runExistDB(){
    echo "runExistDB Start"

    PROCESS_NAME=postgres

    # set permission 700 for running agensgraph
    chmod 700 $AGDATA

    # remove postmaster.pid file
    rm -rf $AGDATA/postmaster.pid

    # starting the server
    ag_ctl start -D $AGDATA
    sleep 10
}

function runBash() {
    /bin/bash
}

function checkProcessStatus(){
  while /bin/true; do
    sleep 60
    ps aux |grep $PROCESS_NAME |grep -q -v grep
    PROCESS_STATUS=$?
    # If the greps above find anything, they will exit with 0 status
    # If they are not both 0, then something is wrong
    if [ $PROCESS_STATUS -ne 0 ]; then
      echo $PROCESS_NAME "Status -->> " $PROCESS_STATUS
      echo "The processes [ $PROCESS_NAME ] has already exited somehow."
      echo "The Container is stopped at `date`."
      exit -1
    fi
  done
}

main

