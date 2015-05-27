#!/bin/bash

for i in `seq 1 40`;
do
    ./get-results.pl http://oficinavirtual.ugr.es/elecciones/graficas/mostrar_recuento_sectores.jsp ../elecciones-ugr.github.io/resultados
    cd ../elecciones-ugr.github.io; git commit -am "Resultados ${i}";git push;cd ../scraper
    sleep 120
done
