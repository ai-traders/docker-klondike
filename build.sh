#!/bin/bash

source ./image/variables.sh
cd image && docker build -t ${this_image_name}:${this_image_tag} --rm .
