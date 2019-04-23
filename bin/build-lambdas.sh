#!/usr/bin/env bash

for function in login resize site-builder; do
  (
    cd $function
    docker build -t "cloudformation-lambda-$function" .
    docker run "cloudformation-lambda-$function" > ../dist/lambda-$function.zip
  )
done