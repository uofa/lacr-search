# CS3028 Team Charlie

LACR Search is Ruby on Rails web application that provides a convenient way to search within a corpus of transcribed documents stored in XML format. 

A primary goal for LACR Search is to contribute to the [Aberdeen Burgh Records Project](https://www.abdn.ac.uk/riiss/about/aberdeen-burgh-records-project-97.php) with user-friendly interface for easy navigation between pages, volumes as well as to enable search queries.

Plain text search, suggestions, autocomplete, spelling variants are provided utilising the utilising the search engine [Elasticsearch](https://www.elastic.co/products/elasticsearch).

LACR Search has been further extended with the ability for further analysis of the XML documents by providing support for [XQuery](https://www.w3schools.com/xml/xquery_intro.asp) expressions utilising [BaseX](http://basex.org/products/).

## Getting Started
LACR Search is composed of several Docker containers providing independentce and isolation from the Host OS.

1.Install [Docker](https://docs.docker.com/engine/installation/)
- [Debian](https://docs.docker.com/v1.12/engine/installation/linux/debian/)
- [Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04#step-1-—-installing-docker)
- [Linux Mint](http://linuxbsdos.com/2016/12/13/how-to-install-docker-and-run-docker-containers-on-linux-mint-1818-1/)
- [Arch linux](https://wiki.archlinux.org/index.php/Docker#Installation)
- [Fedora](https://fedoraproject.org/wiki/Docker)

2.Install [docker-compose](https://docs.docker.com/compose/install/)
```sh
pip install docker-compose
```
3.Navigate to the project directory `lacr-search/` and execute the shell script `setup.sh`
```sh
./setup.sh
```
4.Follow the instructions
