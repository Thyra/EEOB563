make -Bnd | ./make2graph > makefile.dot
dot -omakevile.svg -Tsvg makefile.dot
rm makefile.dot
