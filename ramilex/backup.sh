#!/bin/bash


SCRIPT=`basename $0`

function usage()
{
    echo "Usage: ${SCRIPT} [options]"
    echo "  -s <dir> source directory"
    echo "  -b <dir> backup directory"
    echo "  -d       with daily sub directories"
    echo "  -h       show this usage"
}

WITH_SUBDIRS="no"

while getopts ":hds:b:" opt
do
    case "$opt" in
        s) SOURCE_DIR=$OPTARG;;
        b) TARGET_DIR=$OPTARG;;
        d) WITH_SUBDIRS="yes";;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument!"
            exit 2
            ;;
    esac
done

if [ ! "$SOURCE_DIR" ]
then
    echo "Source directory not given!"
    echo
    usage
    sleep 5
    exit 1
fi

if [ ! "$TARGET_DIR" ]
then
    echo "Backup directory not given!"
    echo
    usage
    sleep 5
    exit 2
fi

PATRICK=patrick@pativo.de
SUBJECT=empty
RESULT=0
BODY=`mktemp`
echo "tmp file : $BODY"

echo "Backup on $HOSTNAME at `date`" > $BODY
echo >> $BODY
echo "Configuration: " >> $BODY
echo " source dir: $SOURCE_DIR" >> $BODY
echo " target dir: $TARGET_DIR" >> $BODY
echo " with daily subdirs: $WITH_SUBDIRS" >> $BODY
echo >> $BODY

if [ ! -d $SOURCE_DIR ]
then
    echo "Source directory $SOURCE_DIR does not exist" >> $BODY
    RESULT=3
fi

if [ ! -d $TARGET_DIR ]
then
    echo "Backup directory $TARGET_DIR does not exist" >> $BODY
    RESULT=4
fi

if [ $WITH_SUBDIRS == "yes" ]
then
    TARGET_DIR=$TARGET_DIR/`date +%a`

    if [ ! -d $TARGET_DIR ]
    then
        mkdir $TARGET_DIR
    fi
fi

if [ $RESULT -eq 0 ]
then
    echo "Backup läuft ... bitte warten"
    echo

    rsync -av $SOURCE_DIR $TARGET_DIR > $TARGET_DIR/backup.log

    RESULT=$?

    if [ $RESULT -ne 0 ]
    then
        echo "Backup fehlgeschlagen!"
        echo
        echo "Patrick bekommt automatisch eine Mail ;-)"
    else
        echo "Backup fertig :-)"
        echo
    fi

    echo "Last run: `date`" >> $TARGET_DIR/backup.log
fi

if [ $RESULT -ne 0 ]
then
    echo "Backup failed with: $RESULT" >> $BODY
    SUBJECT="Backup FAILED"

    echo >> $BODY

    if [ -e $TARGET_DIR/backup.log ]
    then
        cat $TARGET_DIR/backup.log >> $BODY
    fi
else
    echo "Backup successful :-)" >> $BODY
    SUBJECT="Backup OK"
fi


mail -s "$SUBJECT" $PATRICK < $BODY
#cat $BODY


echo "USB Stick kann entfernt werden"
echo "Fenster schließt sich in 10s automatisch"

# clean up
rm $BODY

sleep 10

exit $RESULT

# vim: set et ts=4 sw=4:
