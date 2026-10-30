percent=${1:-2.5}

for tif in *.tif; do
    png="${tif%.tif}.png"
    convert "$tif" -bordercolor white -border "${percent}%x${percent}%" "$png"
    echo "$tif ($(identify -format '%wx%h' "$tif")) -> $png ($(identify -format '%wx%h' "$png"))"
done

fd -e png -x oxipng {}
