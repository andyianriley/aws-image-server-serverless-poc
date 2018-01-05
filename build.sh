#!/bin/bash
set -e

rm -f at_image_resize_lambda.zip && cd src && zip -r ../at_image_resize_lambda.zip * && cd ..
