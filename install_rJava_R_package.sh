#!/usr/bin/env bash

sudo R --no-save -q -e "install.packages('rJava')"
sudo R CMD javareconf -e
echo "finish install rJava"

