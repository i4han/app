#!/usr/bin/env bash

parts install cmake redis meteor
parts start redis
node npm_packages
meteor update
