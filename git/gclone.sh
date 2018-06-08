#!/bin/bash

if [ $# == 0 ]
then
    echo "Usage:" >&2
    echo "    $0 project_name[s]" >&2
    exit 1
fi

function repo_name()
{
    local project=$1
    echo "git@github.com:hujh08/${project}.git"
}

for p in "$@"
do
    echo
    echo "clone project: $p"
    repo=`repo_name $p`
    echo "preject repo: $repo"
    echo git clone $repo
    git clone $repo
done
