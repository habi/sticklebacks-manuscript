#!/bin/bash

# Install dependencies, like in ci/install-spellcheck.sh
# Set options for extra caution & debugging
set -o errexit \
    -o pipefail
# --allow-releaseinfo-change for error on appveyor like "Repository ... changed its 'Label' value"
sudo apt-get update --yes --allow-releaseinfo-change
sudo apt-get install --yes pdftk-java ghostscript enscript
# Commands for linenumbering a PDF
input="$1"
output="${1%.pdf}-num.pdf"
pagenum=$(pdftk "$input" dump_data | grep "NumberOfPages" | cut -d":" -f2)
enscript -L1 --header='|| $%/$=' --output - < <(for i in $(seq "$pagenum"); do echo; done) | ps2pdf - | pdftk "$input" multistamp - output $output