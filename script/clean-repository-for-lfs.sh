#!/bin/sh

git filter-branch --index-filter 'git rm --cached --ignore-unmatch *.JPG' HEAD
git filter-branch --index-filter 'git rm --cached --ignore-unmatch *.png' HEAD
git filter-branch --index-filter 'git rm --cached --ignore-unmatch *.jpg' HEAD



