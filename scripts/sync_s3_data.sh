#!/bin/zsh
BUCKET="s3://nlp-domain-adaptation"


if [ $(basename $(pwd)) != "NLP-Domain-Adaptation" ]; then
    echo "This script is intended to run in the NLP-Domain-Adaptation folder."
    echo "Move to the correct folder before running this again."
    exit 1
fi

# Copy corpus and fine-tuning datasets from S3
DOMAINS=("biology" "law")
SUBDIRECTORIES=("corpus" "tasks")
for domain in $DOMAINS; do
    # Load corpus
    mkdir -p "data/$domain/corpus"
    aws s3 cp "$BUCKET/domains/$domain/corpus/" "data/$domain/corpus" \
      --recursive --exclude "*" --include "*.txt" --exclude "*/*"

    # Load task dataset
    if [ $domain = "biology" ]; then
        mkdir -p "data/$domain/tasks"
        aws s3 cp "$BUCKET/domains/$domain/tasks/" "data/$domain/tasks" --recursive
    fi
done

# Copy cached folders
if ! [ -e results ]; then mkdir results; fi
aws s3 sync "$BUCKET/cache/" "results" --exclude "*checkpoint*"