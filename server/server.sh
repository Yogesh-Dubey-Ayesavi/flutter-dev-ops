#!/bin/bash

# Welcome
echo 'Server start script initialized...'

# Change directories to the release folder
cd build/web/

echo 'Folder now set to' $PWD

# Start the server
echo 'Starting server on port' $PORT '...'
python3 -m http.server $PORT

# Exit
echo 'Server exited...'