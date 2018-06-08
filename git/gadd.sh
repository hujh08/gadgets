#!/bin/bash

if [ $# == 0 ]
then
    echo $PWD
    proj=`basename $PWD`
else
    proj=$1
fi

echo "project: $proj"
echo git remote add origin git@github.com:hujh08/${proj}.git
git remote add origin git@github.com:hujh08/${proj}.git
