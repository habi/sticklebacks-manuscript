#!/bin/bash
input="$1"
output="${1%.pdf}-num.pdf"
pagenum=$(pdftk "$input" dump_data | grep "NumberOfPages" | cut -d":" -f2)
enscript -L1 --header='|| $%/$=' --output - < <(for i in $(seq "$pagenum"); do echo; done) | ps2pdf - | pdftk "$input" multistamp - output $output