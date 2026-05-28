puts "Limpando artigos existentes..."
Article.destroy_all
Tag.destroy_all

puts "Criando categorias..."

categorias_data = [
  { nome: "Política",        cor: "#dc2626", descricao: "Notícias e análises políticas nacionais e internacionais" },
  { nome: "Tecnologia",      cor: "#2563eb", descricao: "Inovação, startups, inteligência artificial e tendências tech" },
  { nome: "Economia",        cor: "#16a34a", descricao: "Mercados financeiros, negócios e economia global" },
  { nome: "Esportes",        cor: "#ea580c", descricao: "Cobertura esportiva completa — futebol, olimpíadas e mais" },
  { nome: "Saúde",           cor: "#9333ea", descricao: "Medicina, bem-estar, ciência e qualidade de vida" },
  { nome: "Mundo",           cor: "#0891b2", descricao: "Acontecimentos internacionais, geopolítica e diplomacia" },
  { nome: "Cultura",         cor: "#d97706", descricao: "Arte, literatura, cinema, música e entretenimento" },
  { nome: "Meio Ambiente",   cor: "#059669", descricao: "Clima, sustentabilidade, biodiversidade e energia limpa" },
]

categorias_data.each do |dados|
  Category.find_or_create_by!(nome: dados[:nome]) do |c|
    c.descricao = dados[:descricao]
    c.cor       = dados[:cor]
    c.ativo     = true
  end
end

pol  = Category.find_by!(nome: "Política")
tech = Category.find_by!(nome: "Tecnologia")
eco  = Category.find_by!(nome: "Economia")
esp  = Category.find_by!(nome: "Esportes")
sau  = Category.find_by!(nome: "Saúde")
mun  = Category.find_by!(nome: "Mundo")
cul  = Category.find_by!(nome: "Cultura")
amb  = Category.find_by!(nome: "Meio Ambiente")

puts "Criando usuários..."

admin = User.find_or_create_by!(email: "admin@buscamais.org") do |u|
  u.nome     = "Admin Busca Mais"
  u.password = "Admin@123456"
  u.role     = :administrador
end

editor = User.find_or_create_by!(email: "editor@buscamais.org") do |u|
  u.nome     = "Editor Chefe"
  u.password = "Editor@123456"
  u.role     = :editor
end

editor2 = User.find_or_create_by!(email: "editora@buscamais.org") do |u|
  u.nome     = "Marina Fonseca"
  u.password = "Editor@123456"
  u.role     = :editor
end

usuario = User.find_or_create_by!(email: "usuario@buscamais.org") do |u|
  u.nome     = "João Silva"
  u.password = "Usuario@123456"
  u.role     = :usuario
end

Subscription.find_or_create_by!(user: usuario) do |s|
  s.plano  = :gratuito
  s.status = :ativa
end

puts "Criando tags..."

tags_nomes = %w[IA Blockchain Sustentabilidade Reforma Eleições Investimentos
                Saúde-Mental Copa Olimpíadas Vacinas Startup Energia Criptomoeda
                Segurança Educação Inflação Desemprego Clima 5G Metaverso]

tags = tags_nomes.map { |n| Tag.find_or_create_by!(nome: n) }

puts "Criando artigos..."

conteudo_base = <<~TEXTO
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

  Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

  Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

  Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.

  At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.
TEXTO

artigos = [
  # ── POLÍTICA ──────────────────────────────────────────────────────────
  { titulo: "Congresso aprova reforma tributária histórica após meses de negociações",
    resumo: "Câmara e Senado chegam a acordo sobre novo sistema de impostos que promete simplificar a vida de empresas e cidadãos.",
    category: pol, destaque: true, author: editor },

  { titulo: "Eleições municipais: pesquisa aponta virada surpreendente nas capitais",
    resumo: "Novo levantamento mostra inversão de tendência nas principais cidades do país a três semanas do pleito.",
    category: pol, destaque: false, author: editor },

  { titulo: "Governo anuncia pacote de medidas para reduzir desigualdade regional",
    resumo: "Investimentos de R$ 50 bilhões voltados para infraestrutura no Norte e Nordeste entram em vigor no próximo mês.",
    category: pol, destaque: false, author: editor2 },

  { titulo: "PEC da Segurança Pública divide opiniões no parlamento",
    resumo: "Proposta que federaliza forças de segurança em casos de crise recebe críticas de especialistas em direito constitucional.",
    category: pol, destaque: false, author: editor },

  { titulo: "Crise diplomática com vizinho sul-americano entra em nova fase",
    resumo: "Ministério das Relações Exteriores convoca embaixador após declarações polêmicas do presidente estrangeiro.",
    category: pol, destaque: true, author: admin },

  { titulo: "Câmara derruba veto presidencial em votação histórica",
    resumo: "Placar apertado de 257 a 213 derruba veto que suspendia reajuste para servidores públicos federais.",
    category: pol, destaque: false, author: editor2 },

  # ── TECNOLOGIA ────────────────────────────────────────────────────────
  { titulo: "OpenAI lança modelo de IA capaz de raciocinar como humanos em múltiplas etapas",
    resumo: "Nova geração de modelos de linguagem combina raciocínio lógico, memória persistente e aprendizado contextual.",
    category: tech, destaque: true, author: editor },

  { titulo: "Brasil sobe para 5° lugar no ranking global de startups de tecnologia",
    resumo: "Ecossistema nacional de inovação atrai US$ 4,2 bilhões em investimentos no primeiro semestre do ano.",
    category: tech, destaque: false, author: editor },

  { titulo: "5G chega a 200 municípios brasileiros com velocidades de até 10 Gbps",
    resumo: "Operadoras concluem implantação de infraestrutura em cidades do interior que permaneciam com 3G.",
    category: tech, destaque: false, author: editor2 },

  { titulo: "Startup brasileira cria bateria de estado sólido que carrega em 5 minutos",
    resumo: "Tecnologia desenvolvida em São Paulo pode revolucionar mercado de veículos elétricos e eletrônicos portáteis.",
    category: tech, destaque: true, author: editor },

  { titulo: "Governo lança política nacional de inteligência artificial",
    resumo: "Marco regulatório define diretrizes para uso responsável de IA em serviços públicos e privados.",
    category: tech, destaque: false, author: admin },

  { titulo: "Ataques cibernéticos a infraestrutura crítica crescem 340% no Brasil",
    resumo: "Relatório do CERT.br aponta hospitais, usinas e sistemas bancários como alvos preferenciais de hackers.",
    category: tech, destaque: false, author: editor2 },

  # ── ECONOMIA ──────────────────────────────────────────────────────────
  { titulo: "Banco Central reduz juros em 0,5 ponto percentual em sinalização dovish",
    resumo: "Taxa Selic cai para 10,25% ao ano em decisão unânime; mercado já precifica novos cortes para o segundo semestre.",
    category: eco, destaque: true, author: editor },

  { titulo: "PIB cresce 3,2% no primeiro trimestre, superando projeções",
    resumo: "Agropecuária e serviços lideram expansão; indústria ainda enfrenta gargalos de produção.",
    category: eco, destaque: false, author: editor },

  { titulo: "Bitcoin supera US$ 120 mil pela primeira vez na história",
    resumo: "Criptomoeda atinge máxima histórica impulsionada por aprovação de novos ETFs spot na Europa e Ásia.",
    category: eco, destaque: false, author: editor2 },

  { titulo: "Inflação fecha mês em 0,22%, menor resultado em 18 meses",
    resumo: "Queda nos preços de alimentos e combustíveis puxa indicador para baixo; IPCA acumulado fica em 3,8% no ano.",
    category: eco, destaque: true, author: editor },

  { titulo: "Bolsa de Valores atinge recorde histórico de 145 mil pontos",
    resumo: "Ibovespa é impulsionado por resultados corporativos acima das expectativas e otimismo com corte de juros.",
    category: eco, destaque: false, author: admin },

  { titulo: "Exportações batem recorde e superam US$ 380 bilhões no semestre",
    resumo: "Commodities agrícolas e minerais lideram crescimento; saldo comercial positivo ultrapassa US$ 60 bilhões.",
    category: eco, destaque: false, author: editor2 },

  # ── ESPORTES ──────────────────────────────────────────────────────────
  { titulo: "Seleção brasileira goleia rival e avança para semifinal da Copa do Mundo",
    resumo: "Com show de gols de Vinicius Jr. e Rodrygo, o Canarinho entra no grupo dos quatro melhores pela décima vez.",
    category: esp, destaque: true, author: editor },

  { titulo: "Flamengo anuncia contratação milionária de atacante europeu",
    resumo: "Clube carioca fecha com artilheiro da Bundesliga por 60 milhões de euros em transferência recorde do futebol nacional.",
    category: esp, destaque: false, author: editor },

  { titulo: "Bia Ferreira conquista ouro olímpico no boxe em Paris",
    resumo: "Pugilista brasileira finaliza rival alemã no segundo round e confirma favoritismo em prova emocionante.",
    category: esp, destaque: false, author: editor2 },

  { titulo: "Fórmula 1: piloto brasileiro vence GP do Brasil em Interlagos",
    resumo: "Com estratégia perfeita de pit stops, compatriota domina corrida do início ao fim sob chuva torrencial.",
    category: esp, destaque: true, author: editor },

  { titulo: "Neymar confirma aposentadoria da Seleção Brasileira em entrevista",
    resumo: "Maior artilheiro da história da Seleção anuncia fim de ciclo e se dedica exclusivamente ao clube.",
    category: esp, destaque: false, author: admin },

  { titulo: "NBA: brasileiro entra no top 10 de pontuadores da história da liga",
    resumo: "Ala-pivô supera marca histórica na vitória da franquia sobre rival direto pela liderança da conferência.",
    category: esp, destaque: false, author: editor2 },

  # ── SAÚDE ─────────────────────────────────────────────────────────────
  { titulo: "Vacina brasileira contra dengue tem eficácia de 93% em ensaio clínico",
    resumo: "Instituto Butantan anuncia resultado histórico; imunizante deve estar disponível pelo SUS até o final do ano.",
    category: sau, destaque: true, author: editor },

  { titulo: "OMS declara fim da emergência de saúde pública por nova variante",
    resumo: "Organização mundial confirma controle epidemiológico e levanta restrições de viagem para países afetados.",
    category: sau, destaque: false, author: editor },

  { titulo: "Câncer de pele: novo medicamento reduz tumores em 87% dos casos",
    resumo: "Pesquisa publicada na Nature Medicine apresenta imunoterapia que elimina metástases resistentes à quimioterapia.",
    category: sau, destaque: false, author: editor2 },

  { titulo: "Brasil registra queda de 35% nos casos de depressão com nova política de saúde mental",
    resumo: "Programa de atenção básica integra psicólogos às UBS e reduz espera por atendimento para menos de 30 dias.",
    category: sau, destaque: true, author: editor },

  { titulo: "Alzheimer: medicamento brasileiro entra em fase 3 de testes clínicos",
    resumo: "Composto desenvolvido pela USP mostra redução de placas amiloides sem os efeitos colaterais dos concorrentes.",
    category: sau, destaque: false, author: admin },

  { titulo: "Estudo revela que jejum intermitente reduz risco cardiovascular em 40%",
    resumo: "Pesquisa acompanhou 12 mil voluntários por 7 anos e confirma benefícios metabólicos da restrição alimentar.",
    category: sau, destaque: false, author: editor2 },

  # ── MUNDO ─────────────────────────────────────────────────────────────
  { titulo: "Acordo histórico de paz encerra conflito de 12 anos no Oriente Médio",
    resumo: "Mediação da ONU e UE resulta em cessar-fogo permanente e cronograma de reconstrução para região devastada.",
    category: mun, destaque: true, author: editor },

  { titulo: "G20 aprova imposto mínimo global de 15% sobre fortunas bilionárias",
    resumo: "Acordo inédito entre as maiores economias deve gerar arrecadação de US$ 250 bilhões anuais para países em desenvolvimento.",
    category: mun, destaque: false, author: editor },

  { titulo: "China lança primeira estação espacial lunar habitável",
    resumo: "Missão Chang'e 10 estabelece base permanente no polo sul da Lua em marco histórico da exploração espacial.",
    category: mun, destaque: false, author: editor2 },

  { titulo: "Europa declara emergência energética e acelera transição para renováveis",
    resumo: "União Europeia investe €800 bilhões em energia solar e eólica para eliminar dependência do gás russo até 2027.",
    category: mun, destaque: true, author: editor },

  { titulo: "Eleições nos EUA: candidatos travam debate histórico sobre IA e economia",
    resumo: "Polarização recorde marca disputa presidencial americana com questões tecnológicas dominando a agenda.",
    category: mun, destaque: false, author: admin },

  # ── CULTURA ───────────────────────────────────────────────────────────
  { titulo: "Série brasileira vence Emmy Internacional de melhor drama",
    resumo: "Produção da Globoplay supera concorrentes de 43 países e consolida prestígio do audiovisual nacional no exterior.",
    category: cul, destaque: true, author: editor },

  { titulo: "Museu Nacional reabre com acervo restaurado após incêndio devastador",
    resumo: "Cinco anos de trabalho resultam na recuperação de 5 mil peças históricas; nova ala conta história do Brasil pré-colonial.",
    category: cul, destaque: false, author: editor2 },

  { titulo: "Festival de Cinema de Brasília bate recorde de público com 300 mil visitantes",
    resumo: "Edição comemorativa de 50 anos reuniu obras de 60 países e consagrou novos talentos do cinema brasileiro.",
    category: cul, destaque: false, author: editor },

  { titulo: "Artista plástico brasileiro arrecada R$ 45 milhões em leilão em Nova York",
    resumo: "Obra 'Raízes do Cerrado' se torna a pintura mais cara de um artista brasileiro vivo na história.",
    category: cul, destaque: true, author: admin },

  # ── MEIO AMBIENTE ─────────────────────────────────────────────────────
  { titulo: "Desmatamento na Amazônia cai 68% e atinge menor nível em 30 anos",
    resumo: "Dados do INPE confirmam reversão histórica; políticas de monitoramento e fiscalização são apontadas como determinantes.",
    category: amb, destaque: true, author: editor },

  { titulo: "Brasil bate recorde: 95% da energia elétrica vem de fontes renováveis",
    resumo: "Hidrelétricas, solar e eólica somadas tornam matriz energética nacional uma das mais limpas do planeta.",
    category: amb, destaque: false, author: editor },

  { titulo: "Nova espécie de planta descoberta no Cerrado promete tratamento para diabetes",
    resumo: "Pesquisadores da UnB identificam composto em planta endêmica que reduz glicemia sem efeitos colaterais.",
    category: amb, destaque: false, author: editor2 },

  { titulo: "COP30 no Brasil: países ricos comprometem US$ 1 trilhão para combate ao clima",
    resumo: "Conferência em Belém estabelece metas ambiciosas de descarbonização e fundo histórico para nações vulneráveis.",
    category: amb, destaque: true, author: admin },

  { titulo: "Recife implementa sistema de alerta precoce para enchentes e salva 12 mil famílias",
    resumo: "Tecnologia de sensores e IA monitora rios em tempo real e envia alertas até 6 horas antes das cheias.",
    category: amb, destaque: false, author: editor2 },
]

artigos.each_with_index do |dados, i|
  a = Article.find_or_create_by!(titulo: dados[:titulo]) do |art|
    art.resumo      = dados[:resumo]
    art.conteudo    = "#{dados[:resumo]}\n\n#{conteudo_base}"
    art.category    = dados[:category]
    art.destaque    = dados[:destaque]
    art.status      = :publicado
    art.author      = dados[:author]
    art.publicado_em = Time.current - (i * 4).hours - rand(0..3).hours
  end

  # associa 2-3 tags aleatórias
  a.tags = tags.sample(rand(2..3)) if a.article_tags.empty?
end

puts "Criando planos de assinatura..."

SubscriptionPlan.find_or_create_by!(slug: "gratuito") do |p|
  p.nome     = "Gratuito"
  p.descricao = "Ideal para gerar tráfego e engajamento básico."
  p.preco    = 0
  p.posicao  = 1
  p.cor      = "gray"
  p.ativo    = true
  p.destaque = false
  p.beneficios = [
    "Leitura ilimitada de matérias",
    "Comentar em artigos",
    "Curtir comentários",
    "Escolher categorias de interesse",
    "Salvar até 20 matérias",
    "Responder comentários",
    "Editar comentário por até 5 minutos"
  ]
  p.permissoes = {
    "salvar_materias_limite"              => 20,
    "editar_comentario_minutos"           => 5,
    "moderacao_automatica"                => true,
    "delay_entre_comentarios"             => true,
    "aprovacao_automatica_apos_reputacao" => false,
    "badge"                               => nil,
    "notificacoes_avancadas"              => false,
    "historico_comentarios"               => false,
    "pode_denunciar"                      => false,
    "pode_seguir"                         => false,
    "destaque_visual_comentarios"         => false,
    "pode_fixar_comentario"               => false,
    "acesso_antecipado"                   => false,
    "pode_criar_enquetes"                 => false,
    "sem_anuncios"                        => false
  }
end

SubscriptionPlan.find_or_create_by!(slug: "plus") do |p|
  p.nome     = "Plus"
  p.descricao = "Usuário ativo e recorrente. Mais recursos para participar."
  p.preco    = 19.90
  p.posicao  = 2
  p.cor      = "blue"
  p.ativo    = true
  p.destaque = true
  p.beneficios = [
    "Aprovação automática após reputação mínima",
    "Editar comentário por até 30 minutos",
    "Salvar matérias ilimitadas",
    "Badge Plus exclusivo",
    "Notificações avançadas",
    "Histórico completo de comentários",
    "Comentário sobe mais rápido",
    "Pode denunciar comentários",
    "Pode seguir autores e categorias",
    "Experiência sem anúncios"
  ]
  p.permissoes = {
    "salvar_materias_limite"              => 0,
    "editar_comentario_minutos"           => 30,
    "moderacao_automatica"                => false,
    "delay_entre_comentarios"             => false,
    "aprovacao_automatica_apos_reputacao" => true,
    "badge"                               => "plus",
    "notificacoes_avancadas"              => true,
    "historico_comentarios"               => true,
    "pode_denunciar"                      => true,
    "pode_seguir"                         => true,
    "destaque_visual_comentarios"         => false,
    "pode_fixar_comentario"               => false,
    "acesso_antecipado"                   => false,
    "pode_criar_enquetes"                 => false,
    "sem_anuncios"                        => true
  }
end

SubscriptionPlan.find_or_create_by!(slug: "max") do |p|
  p.nome     = "MAX"
  p.descricao = "Comunidade forte. O máximo da experiência Busca Mais."
  p.preco    = 39.90
  p.posicao  = 3
  p.cor      = "purple"
  p.ativo    = true
  p.destaque = false
  p.beneficios = [
    "Tudo do plano Plus",
    "Destaque visual nos comentários",
    "Fixar comentário próprio por tempo limitado",
    "Nome com badge MAX especial",
    "Acesso antecipado a matérias",
    "Sem limite de salvamento",
    "Pode criar enquetes em comentários",
    "Moderação comunitária avançada",
    "Suporte prioritário"
  ]
  p.permissoes = {
    "salvar_materias_limite"              => 0,
    "editar_comentario_minutos"           => 60,
    "moderacao_automatica"                => false,
    "delay_entre_comentarios"             => false,
    "aprovacao_automatica_apos_reputacao" => true,
    "badge"                               => "max",
    "notificacoes_avancadas"              => true,
    "historico_comentarios"               => true,
    "pode_denunciar"                      => true,
    "pode_seguir"                         => true,
    "destaque_visual_comentarios"         => true,
    "pode_fixar_comentario"               => true,
    "acesso_antecipado"                   => true,
    "pode_criar_enquetes"                 => true,
    "sem_anuncios"                        => true
  }
end

puts ""
puts "✓ Seeds criados com sucesso!"
puts ""
puts "  #{Category.count} categorias | #{Article.count} artigos | #{Tag.count} tags"
puts "  #{Article.destaques.count} artigos em destaque | #{Article.publicados.count} publicados"
puts "  #{SubscriptionPlan.count} planos de assinatura"
puts ""
puts "Usuários:"
puts "  admin@buscamais.org    | Admin@123456    | administrador"
puts "  editor@buscamais.org   | Editor@123456   | editor"
puts "  editora@buscamais.org  | Editor@123456   | editor"
puts "  usuario@buscamais.org  | Usuario@123456  | usuario"
