#!/bin/bash

for i in 1..120; do
    ./get-resultados.pl http://oficinavirtual.ugr.es/elecciones/mostrar_detalles.jsp ../elecciones-ugr.github.io/resultados
    cd ../elecciones-ugr.github.io; git commit -am "Resultados ${i}";git push
    sleep 120
done
