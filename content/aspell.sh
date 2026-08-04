for i in 0[1234569]*.md;
do aspell -c $i -l en-us;
done
rm 0[1234569]*.md.bak
