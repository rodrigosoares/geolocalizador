# encoding: utf-8
require_relative 'classes/instalagem'
require_relative 'classes/localizacao'
require 'time'
carrega_gem 'geocoder'

# Expressões regulares para capturar o IP e a data das ocorrências.
IP_REGEX = %r{\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}}
DATA_REGEX = %r{\w{3}\s{1,2}\d{1,2}}

# Trechos de ocorrências válidas.
TRECHOS_VALIDOS = ["Received disconnect from", "Did not receive identification", "Connection closed"]

# Vetor com todas as localizações obtidas.
@lista_locais = []

# Vetor com os endereços IP a serem ignorados da varredura.
@lista_ignorados = []

# Imprime o banner da ferramenta com créditos e instruções.
def imprime_banner
  puts "GEOLOCALIZADOR DE IP - desenvolvido por Rodrigo Soares e Silva, e-mail: rodrigosoares@id.uff.br"
  puts
  puts "Esta ferramenta processa e localiza os IPs registrados em arquivos de logs gerados pelo servidor SSH. " +
    "Em seguida, exporta as informações das tentativas de conexão e as coordenadas gráficas baseadas em longitudes e " +
    "ocorrências em arquivos textuais nesta mesma pasta."
  puts
  puts "uso: 'ruby geolocalizador.rb <arquivo>'"
end

# Obtém os endereços IP a serem ignorados da varredura.
def obtem_ips_ignorados(caminho_ips_ignorados)
  if caminho_ips_ignorados.nil?
    puts "Não foi especificado um arquivo de IPs ignorados. Todos os IPs serão processados."
  else
    begin
      arquivo = File.open caminho_ips_ignorados, 'r'
      arquivo.each_line do |linha|
        @lista_ignorados << linha.match(IP_REGEX).to_s
      end
      arquivo.close
    rescue Errno::ENOENT
      puts 'Arquivo de IPs ignorados não encontrado. Todos os IPs serão processados.'
    end
  end
end

# Insere uma nova localização na lista ou, se já existir, incrementa seu número de ocorrências.
def insere_localizacao ip, data
  existe = false
  @lista_locais.each do |local|
    if local.ip == ip
      local.ocorrencias += 1
      existe = true
    end
  end
  unless existe
    info = Geocoder.search(ip).first
    @lista_locais << Localizacao.new(info.ip, info.country, info.city, info.longitude, data)
  end
end

# Verifica se a linha é válida para varredura.
def linha_valida? linha
  TRECHOS_VALIDOS.any? { |trecho| linha.include? trecho }
end

# Retorna a menor data de ocorrência da lista de localizações.
def data_inicial
  @lista_locais.min { |a, b| a.data <=> b.data }.data
end

# Retorna a maior data de ocorrência da lista de localizações.
def data_final
  @lista_locais.max { |a, b| a.data <=> b.data }.data
end

# Calcula a média diária de ocorrências.
def media_diaria(total)
  total/(data_final - data_inicial).to_i
end

# Ordena a lista de locais pelas longitudes.
def ordena_infos_por_longitude
  puts "Ordenando informações..."
  @lista_locais.sort! { |a, b| a.longitude <=> b.longitude }
end

# Exporta as informações colhidas na varredura para um arquivo textual.
def exporta_infos
  puts "Exportando informações..."
  rotulo = "infos_geolocalizador_#{Time.now.strftime '%d%m%y_%H%M%S'}.txt"
  arquivo = File.new rotulo, "w"
  total_ocorrencias = 0
  @lista_locais.each do |local|
    arquivo.puts "IP: #{local.ip} -- data: #{local.data.strftime '%d/%m'} -- cidade: #{local.cidade} -- país: #{local.pais} -- ocorrências: #{local.ocorrencias}"
    total_ocorrencias += local.ocorrencias
  end
  arquivo.puts "TOTAL: #{total_ocorrencias} ocorrências entre #{data_inicial.strftime '%d/%m/%Y'} e #{data_final.strftime '%d/%m/%Y'}"
  arquivo.puts "MÉDIA: #{media_diaria total_ocorrencias} ocorrências/dia"
  arquivo.close
  puts "Arquivo de informações #{rotulo} gerado."
end

# Exporta as longitudes das origens e respectivas ocorrências em coordenadas gráficas para um arquivo textual.
def exporta_longitudes
  puts "Exportando coordenadas..."
  rotulo = "coords_geolocalizador_#{Time.now.strftime '%d%m%y_%H%M%S'}.dat"
  arquivo = File.new rotulo, "w"
  @lista_locais.each { |local| arquivo.puts "#{local.longitude} #{local.ocorrencias}" }
  arquivo.close
  puts "Arquivo de coordenadas gráficas #{rotulo} gerado."
end

# Processa o arquivo de logs.
def processa_arquivo(caminho_logs = nil, caminho_ips_ignorados = nil)
  if caminho_logs.nil?
    imprime_banner
  else
    begin
      obtem_ips_ignorados caminho_ips_ignorados
      arquivo = File.open caminho_logs, 'r'
      puts "Processando arquivo #{caminho_logs}..."
      arquivo.each_line do |linha|
        if linha_valida? linha
          ip_match = linha.match IP_REGEX
          if !ip_match.nil? && !@lista_ignorados.include?(ip_match.to_s)
            data_match = linha.match DATA_REGEX
            insere_localizacao ip_match.to_s, Date.parse(data_match.to_s)
          end
        end
      end
      arquivo.close
      ordena_infos_por_longitude
      exporta_infos
      exporta_longitudes
      puts "OK."
    rescue Errno::ENOENT
      puts "Arquivo não encontrado."
    end
  end
end

caminho_log = ARGV[0]
caminho_ips_ignorados = ARGV[1]
processa_arquivo(caminho_log, caminho_ips_ignorados)
