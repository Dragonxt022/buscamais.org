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

  desc "Reescreve matérias importadas pendentes (limite e feed opcionais)"
  task :reescrever, [ :limite, :feed_id ] => :environment do |_tarefa, args|
    limite  = args[:limite].presence || ReescritaArtigosJob::LIMITE_PADRAO
    feed_id = args[:feed_id].presence

    resultado = ReescritaArtigosJob.new.perform(feed_id: feed_id, limite: limite)

    if resultado.nil?
      puts "Não foi possível iniciar o reprocessamento. Veja o log para detalhes."
    else
      sucessos, total = resultado
      if total.to_i.zero?
        puts "Nenhuma matéria pendente para reescrever."
      else
        puts "#{sucessos}/#{total} matéria(s) reescrita(s)."
      end
    end
  end
end
