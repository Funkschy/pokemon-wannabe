#!/bin/bash

make dist/index.js
git add dist
git commit -m "update dist"
git subtree push --prefix dist origin gh-pages
