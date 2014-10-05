#!/bin/bash

# Note that this only works if the tests were built and linked using the
# profiling flags.
if [ "$CXX" == "g++" ];
then
  sudo pip install cpp-coveralls
  coveralls -b . -r . -E '.*CMake.*\.cpp' -t "${COVERALLS_TOKEN}"
fi
