#!/bin/sh
./node_modules/hexo-cli/bin/hexo g
git add source/
git add docs/
git commit -a -m "Updated:$(date "+%Y%m%d-%H:%M:%S")"
git push
