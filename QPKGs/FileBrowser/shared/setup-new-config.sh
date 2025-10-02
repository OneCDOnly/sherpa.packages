#!/usr/bin/env bash

./repo-cache/filebrowser config init -d ./config/filebrowser.db
./repo-cache/filebrowser config set -p 8641 -a '0.0.0.0' -d ./config/filebrowser.db
./repo-cache/filebrowser users add admin 'iwillchangethispassword' -d ./config/filebrowser.db			# Use this to add an admin user with a password
./repo-cache/filebrowser config set --auth.method=noauth -d ./config/filebrowser.db						# Use this for LAN-only access with no-login required.
