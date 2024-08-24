#!/bin/bash

# Get the number of commits
commit_count=$(git rev-list --count HEAD)

# Update the pubspec.yaml file with the new build number
sed -i '' "s/version: \(.*\)+.*/version: \1+$commit_count/" ../pubspec.yaml