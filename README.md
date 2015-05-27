# scraper

Extractor de los datos de la web de las elecciones de la UGR.

Una muestra de la página está en [`muestra.html`](muestra.html).

## Instalación

Necesitas tener perl, python y la librería de Python para Twitter,

    sudo apt-get install python-tweepy

El script de python es el que se usa para postear en Twitter

## Uso

Si tienes [`perlbrew`](http://perlbrew.pl) o `cpanminus` instalado,

```
	cpanm --installdeps .
	./get-results.pl http://url.de.elecciones.ugr.es
```
