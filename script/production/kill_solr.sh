#!/bin/sh

kill -9 `ps aux | grep solr | grep -v grep | awk '{print $2}'`