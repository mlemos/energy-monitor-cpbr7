#app.rb
require "sinatra"
require "sinatra/activerecord"

set :bind, '192.168.0.100'
set :port, 4000
set :database, "sqlite3:///monitor.db"

class Medida < ActiveRecord::Base
end


# dashboard do servidor com várias informações sobre as medidas
get "/dashboard" do
  # estamos pegando todas as medidas do dia, não faça isto na vida real!
	@medidas = Medida.where("DATE(created_at) = DATE(?)", Time.now)
  @consumo = 0
  medida_anterior = nil
  @medidas.each do |medida|
    if medida_anterior
      var_tempo = medida.created_at - medida_anterior.created_at
      energia = (medida.potencia + medida_anterior.potencia) * var_tempo / 2
      @consumo = @consumo + energia # em Joules
    end
    medida_anterior = medida
  end
  @consumo = @consumo / 3600000 # convertendo em kWh
	erb :dashboard
end

# recebe dados de uma nova medida e armazena no banco de dados
get "/medida" do
  return 'ignore' if @params['potencia'].to_f > 2000
	@medida = Medida.new(
    :irms => @params['irms'],
    :potencia => @params['potencia']
  )
	begin
    if @medida.save
  		'ok'
  	else
  		'nok'
  	end
  rescue Exception => e
    e.to_s
  end 
end

# retorna todas as medidas no formato CSV (utilizada para montar o gráfico)
get "/medidas" do
  @medidas = Medida.where("DATE(created_at) = DATE(?)", Time.now)
  csv = "hora,potencia\n";
  @medidas.each do |medida|
    if medida.potencia # enviar apenas medidas corretas
      csv = csv + medida.created_at.to_s.sub(" UTC","") + "," + medida.potencia.to_s + "\n"
    end
  end
  csv
end
