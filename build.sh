#!/bin/bash

docker build -t tensorflow-serving-builder .
docker run -v "${PWD}/:/artifacts" tensorflow-serving-builder

