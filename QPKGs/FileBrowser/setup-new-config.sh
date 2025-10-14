#!/usr/bin/env bash

./repo-cache/filebrowser config init --database ./config/filebrowser.db
./repo-cache/filebrowser config set --port 8641 --address '0.0.0.0' --root / --singleClick --database ./config/filebrowser.db
./repo-cache/filebrowser users add admin 'iwillchangethispassword' --database ./config/filebrowser.db		# To add an 'admin' user with a password.
./repo-cache/filebrowser config set --auth.method=noauth --database ./config/filebrowser.db					# For LAN-only access with no-login required.
