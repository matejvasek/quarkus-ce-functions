#!/bin/bash

mkdir -p ~/.m2/repository/io
tar fx quarkus-mvn.tar.gz -C ~/.m2/repository/io


which java 2>&1 >/dev/null ; JAVA_KNOWN=$?
if [ ! -z "$JAVA_HOME" ] || [ $JAVA_KNOWN = "0" ]; then
  ./mvnw install -Denforcer.skip=true
fi
