#!/usr/bin/env bash

# export DOTNET_BUNDLE_EXTRACT_BASE_DIR=$HOME/.dotnet/bundles

# export LD_LIBRARY_PATH=/share/Public/lib/
# export LD_LIBRARY_PATH=$HOME/local-workspace/lib/
# /share/Public/lib/ld-linux-x86-64.so.2 /opt/bin/python3 /share/Public/nzbhydra2-9.0.1-amd64-linux/nzbhydra2wrapperPy3.py

# LD_LIBRARY_PATH=/share/CACHEDEV1_DATA/.qpkg/Sportarr/lib /share/CACHEDEV1_DATA/.qpkg/Sportarr/lib/ld-linux-x86-64.so.2 /share/CACHEDEV1_DATA/.qpkg/Sportarr/Sportarr

# $HOME/local-workspace/lib/ld-linux-x86-64.so.2 $HOME/local-workspace/Lidarr/Lidarr --help



# [/share/CACHEDEV1_DATA/.qpkg/Sportarr/repo-cache] #
# cd /share/CACHEDEV1_DATA/.qpkg/Sportarr/repo-cache
cd $HOME/local-workspace/Sportarr-linux-x64-4.1.9.1119

# LD_LIBRARY_PATH=/share/CACHEDEV1_DATA/.qpkg/Sportarr/lib/ /share/CACHEDEV1_DATA/.qpkg/Sportarr/lib/ld-linux-x86-64.so.2 ./Sportarr
export LD_LIBRARY_PATH=$HOME/local-workspace/lib/:$HOME/local-workspace/lib64/
# /share/CACHEDEV1_DATA/.qpkg/Sportarr/lib/ld-linux-x86-64.so.2 /share/CACHEDEV1_DATA/.qpkg/Sportarr/repo-cache/Sportarr
$HOME/local-workspace/lib64/ld-linux-x86-64.so.2 ./Sportarr
