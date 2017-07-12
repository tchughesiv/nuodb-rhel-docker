#!/usr/bin/env bash

disable_thp() {

    echo "Checking to see if THP needs to be disabled..."
    THP_BASE=/sys/kernel/mm/transparent_hugepage
    if [ ! -f ${THP_BASE}/enabled ]; then
        THP_BASE=/sys/kernel/mm/redhat_transparent_hugepage
        if [ ! -f ${THP_BASE}/enabled ] ; then
            die "unable to find THP enable file"
        fi
    fi
    THP_ENABLED=${THP_BASE}/enabled
    THP_DEFRAG=${THP_BASE}/defrag
    THP_WAS_ENABLED=false
    grep "\[always\]" ${THP_ENABLED}
    if [ $? -eq 0 ]; then
        THP_WAS_ENABLED=true
        echo "THP is enabled on this machine - this script will temporarily disable it"
        echo madvise> ${THP_ENABLED}
        if [ $? -ne 0 ]; then

            die "Cannot automatically disable THP on a readonly file system - See http://doc.nuodb.com/display/doc/Linux+Installation#LinuxInstallation-DisablingTHPonRead-OnlyFileSystems"
        else
            echo madvise> ${THP_DEFRAG}
        fi
    else
        echo "THP is not enabled on this machine - No action taken"
    fi
}

disable_thp