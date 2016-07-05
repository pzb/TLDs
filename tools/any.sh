#!/bin/bash
drill -D -t @"$1" "$2" ANY | ldns-read-zone -z > "$2"
