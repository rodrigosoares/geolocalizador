#Geolocalizador - versão 1.0

*Geolocalizador* é uma ferramenta de extração de dados estatísticos de arquivos de log gerados pelo serviço SSH e foi desenvolvida como parte do trabalho de conclusão de curso intitulado "Negação de Serviço na Nuvem", do Bacharelado em Ciência da Computação da Universidade Federal Fluminense.

##Uso

A ferramenta recebe como parâmetros o arquivo de log SSH e, opcionalmente, um arquivo de endereços IP a serem ignorados na varredura. O arquivo de endereços IPs a serem ignorados deve ser textual e dispor um endereço por linha.

Uso: `$ ruby geolocalizador.rb [arquivo_logs] [arquivo_ips_ignorados]`

Requer a linguagem Ruby instalada para ser executada.

##Características da versão 1.0

* Extrai o total de ocorrências, a média diária, o país de origem dos endereços IP e o total de ocorrências de cada origem.
* Execução via console.
* Gera um arquivo textual com os resultados e outro arquivo com as longitudes e respectivas ocorrências.
* Desenvolvida na linguagem Ruby versão 1.9.3.

##Bibliotecas de terceiros

Esta ferramenta usa uma biblioteca chamada Geocoder, que pode ser encontrada [aqui](http://www.rubygeocoder.com/).

##Aviso

Esta ferramenta é disponibilizada para fins educativos, com o intuito de servir em pesquisas relacionadas à área de Redes e Segurança da Informação. O autor **não se responsabiliza** pelo mau uso desta ferramenta.
