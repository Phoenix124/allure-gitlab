#!/bin/bash

mkdir -p target/allure-results/history
for D in public/*; do
  find $(find public/* -mindepth 1 -maxdepth 2 -name 'history') -mindepth 1 -maxdepth 1 -type f \( -name '*.json' \) -exec cp "{}" target/allure-results/history/ \;
done
if [ 4 -lt $(find public -mindepth 1 -maxdepth 1 -type d | wc -l) ]; then
  rm -rf "$(find public -mindepth 1 -maxdepth 1 -type d | sort -nr | tail -1)"
fi
mvn io.qameta.allure:allure-maven:report -DpipelineId=$CI_PIPELINE_ID

mv public/$CI_PIPELINE_ID/allure-maven-plugin/* public/$CI_PIPELINE_ID/
find public/ -type d -name "allure-maven-plugin" -exec rm -rf {} +

json=""
for dir in $(find public -mindepth 1 -maxdepth 1 -type d); do
  json="${json},${dir//public\//}"
done
json="$(echo $json | sed 's/^,//')"
cat scripts/index.html | sed "s/'%pipelines%'/$json/" >public/index.html

echo "\n\n\n\n================================= ALLURE REPORT =========================================="
echo {PAGES_URL}/$CI_PIPELINE_ID
echo "==========================================================================================\n\n\n\n"
