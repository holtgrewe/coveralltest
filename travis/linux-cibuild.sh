#!/bin/bash

trap popd EXIT

# get some infos from git to embed it in the build name
export SOURCE_DIRECTORY=`pwd`
mkdir -p _build && pushd _build

# define the build name
if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  export BUILD_NAME=${TRAVIS_PULL_REQUEST}
elif [[ -n "${TRAVIS_COMMIT_RANGE}" ]]; then
  export BUILD_NAME=${TRAVIS_COMMIT_RANGE}
else
  export BUILD_NAME=${TRAVIS_COMMIT}
fi

# disable OpenMP warnings for clang
if [ "${CXX}" == "clang++" ]; then
  export CXXFLAGS="${CXXFLAGS} -DSEQAN_IGNORE_MISSING_OPENMP=1"
fi

# enable gcov flags for GCC.
if [ "${CXX}" == "g++" ]; then
  export CXXFLAGS="${CXXFLAGS} --coverage"
  export LDFLAGS="${LDFLAGS} --coverage"

  echo "CXXFLAGS=${CXXFLAGS}"
  echo "LDFLAGS=${LDFLAGS}"
fi

ctest -V -S ../travis/linux-cibuild.cmake

# we indicate build failures if ctest experienced any errors
if [ -f ${SOURCE_DIRECTORY}/failed ]; then
  exit -1
fi

FAILED_TEST=$(find . -name "Test.xml" -type f | xargs grep "<Test Status=\"failed\">" -c)

if [ "${FAILED_TEST}" -gt "0" ]; then
    exit -1
fi

# it seems like everything worked
exit 0
