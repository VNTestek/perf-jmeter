#!/bin/bash

resFol=$1
# Set the folder to search. You can change this to the folder you want.
folder="../../res/${resFol}"

# Get the current date and time
day=$(date +%d)
month=$(date +%m)
year=$(date +%Y)
hour=$(date +%H)
minute=$(date +%M)
second=$(date +%S)

timestamp="${year}${month}${day}-${hour}${minute}${second}"

echo "Searching for .jtl files in $folder and its sub folders..."

mkdir -p res/${resFol}

# Use the 'find' command to find all .jtl files
find "$folder" -type f -name "*.jtl" | while read -r file; do
  echo "Processing $file"
  filename=$(basename "$file")
  ../../bin/JMeterPluginsCMD.sh --generate-csv "res/${resFol}/${timestamp}-res-convert/${filename}.csv" --input-jtl "$file" --plugin-type AggregateReport
done

# Generate the Testek Report
java -jar ExportAggregateReport-1.0.jar "res/${resFol}/${timestamp}-res-convert"

echo "Done"