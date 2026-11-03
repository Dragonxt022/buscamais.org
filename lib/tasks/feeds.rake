namespace :feeds do
  desc "Sincroniza agora as fontes RSS cujo intervalo já venceu"
  task sync: :environment do
    fontes = FeedSource.ativos.to_a.select(&:devido?)

    if fontes.empty?
      puts "Nenhum feed vencido para sincronizar."
      next
    end

    fontes.each do |feed|
      resultado = feed.sincronizar!
      puts "#{feed.nome}: #{resultado.mensagem}"
    end
  end

  desc "Força a sincronização de uma fonte pelo ID, ignorando o intervalo"
  task :sync_one, [ :id ] => :environment do |_tarefa, args|
    feed = FeedSource.find(args[:id])
    resultado = feed.sincronizar!
    puts "#{feed.nome}: #{resultado.mensagem}"
  end
end
