require "net/http"
require "uri"
require "resolv"
require "ipaddr"
require "time"

# Busca um feed RSS/Atom e transforma cada item novo em um Article.
#
# Regras importantes:
# - deduplica por guid/id externo e também pela URL original (fonte_url);
# - importa no máximo `feed.limite_por_sincronizacao` itens por rodada;
# - baixa a imagem de capa para o Active Storage (quando configurado);
# - nunca deixa uma falha de item derrubar a sincronização inteira.
class FeedSyncService
  Resultado = Struct.new(:importados, :ignorados, :erros, :mensagem, keyword_init: true) do
    def sucesso?
      erros.to_i.zero?
    end
  end

  Item = Struct.new(:titulo, :link, :guid, :publicado_em, :resumo, :conteudo,
                    :categorias, :imagem_url, keyword_init: true)

  NS = {
    "content" => "http://purl.org/rss/1.0/modules/content/",
    "media"   => "http://search.yahoo.com/mrss/",
    "atom"    => "http://www.w3.org/2005/Atom",
    "dc"      => "http://purl.org/dc/elements/1.1/"
  }.freeze

  USER_AGENT         = "BuscaMaisFeedBot/1.0 (+https://buscamais.org)"
  MAX_XML_BYTES      = 10 * 1024 * 1024
  MAX_IMAGE_BYTES    = 8 * 1024 * 1024
  MAX_REDIRECTS      = 3
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  TAGS_PERMITIDAS    = %w[p br strong em b i u h2 h3 h4 ul ol li blockquote a].freeze
  ATRIBUTOS_PERMITIDOS = %w[href rel target].freeze

  def initialize(feed, xml: nil)
    @feed = feed
    @xml  = xml
  end

  def chamar
    importados = 0
    ignorados  = 0
    erros      = 0

    doc = Nokogiri::XML(corpo_do_feed) { |config| config.nonet }
    raise "O endereço não devolveu um feed RSS/Atom válido" if doc.root.nil?
    raise "Nenhum autor disponível para assinar as matérias importadas" if autor.nil?

    itens = extrair_itens(doc)

    itens.first(@feed.limite_por_sincronizacao.to_i).each do |item|
      begin
        importar_item(item) ? importados += 1 : ignorados += 1
      rescue => e
        erros += 1
        Rails.logger.error("[FeedSyncService:#{@feed.id}] #{e.class}: #{e.message}")
      end
    end

    mensagem = "#{importados} nova(s), #{ignorados} já existente(s)/inválida(s)"
    mensagem += ", #{erros} erro(s)" if erros.positive?
    registrar_resultado(erros.positive? ? "parcial" : "ok", mensagem, importados)

    Resultado.new(importados: importados, ignorados: ignorados, erros: erros, mensagem: mensagem)
  rescue => e
    mensagem = "Falha ao sincronizar: #{e.message.to_s.truncate(300)}"
    Rails.logger.error("[FeedSyncService:#{@feed.id}] #{e.class}: #{e.message}")
    registrar_resultado("erro", mensagem, 0)
    Resultado.new(importados: 0, ignorados: 0, erros: 1, mensagem: mensagem)
  end

  private

  def corpo_do_feed
    return @xml if @xml.present?

    corpo, charset = requisitar(@feed.url, limite_bytes: MAX_XML_BYTES, timeout_leitura: 30)
    normalizar_texto(corpo, charset)
  end

  def registrar_resultado(status, mensagem, importados)
    @feed.update_columns(
      ultima_sincronizacao_em: Time.current,
      ultimo_status: status,
      ultima_mensagem: mensagem,
      total_importados: @feed.total_importados.to_i + importados,
      updated_at: Time.current
    )
  end

  # ── Parsing ────────────────────────────────────────────────────────────────

  def extrair_itens(doc)
    itens =
      case doc.root&.name
      when "feed"
        doc.xpath("/atom:feed/atom:entry", NS).map { |node| item_atom(node) }
      when "rss"
        doc.xpath("/rss/channel/item").map { |node| item_rss(node) }
      when "RDF"
        # RSS 1.0 (RDF), usado por alguns sites antigos.
        doc.xpath("//item").map { |node| item_rss(node) }
      else
        raise "O endereço não devolveu um feed RSS/Atom válido"
      end

    itens.compact.sort_by { |item| item.publicado_em || Time.at(0) }.reverse
  end

  def item_rss(node)
    descricao = texto(node.at_xpath("description"))
    html      = texto(node.at_xpath("content:encoded", NS)).presence || descricao
    return nil if html.blank?

    Item.new(
      titulo:       texto(node.at_xpath("title")),
      link:         texto(node.at_xpath("link")),
      guid:         texto(node.at_xpath("guid")),
      publicado_em: parse_data(texto(node.at_xpath("pubDate")).presence || texto(node.at_xpath("dc:date", NS))),
      resumo:       descricao,
      conteudo:     html,
      categorias:   node.xpath("category").map { |cat| texto(cat) }.reject(&:blank?),
      imagem_url:   extrair_imagem_url(node, html)
    )
  end

  def item_atom(node)
    resumo = texto(node.at_xpath("atom:summary", NS))
    html   = texto(node.at_xpath("atom:content", NS)).presence || resumo
    return nil if html.blank?

    link_node = node.at_xpath("atom:link[@rel='alternate']", NS) || node.at_xpath("atom:link", NS)

    Item.new(
      titulo:       texto(node.at_xpath("atom:title", NS)),
      link:         link_node&.[]("href").to_s.strip,
      guid:         texto(node.at_xpath("atom:id", NS)),
      publicado_em: parse_data(texto(node.at_xpath("atom:published", NS)).presence ||
                               texto(node.at_xpath("atom:updated", NS))),
      resumo:       resumo,
      conteudo:     html,
      categorias:   node.xpath("atom:category", NS).map { |cat| cat["term"].presence || texto(cat) }.reject(&:blank?),
      imagem_url:   extrair_imagem_url(node, html)
    )
  end

  def extrair_imagem_url(node, html)
    urls = []

    node.xpath("enclosure").each do |enc|
      urls << enc["url"] if enc["url"].present? && enc["type"].to_s.start_with?("image/")
    end
    node.xpath("media:content", NS).each { |media| urls << media["url"] if media["url"].present? }
    node.xpath("media:thumbnail", NS).each { |media| urls << media["url"] if media["url"].present? }

    urls << primeiro_img(html) if urls.empty?
    urls.compact.first
  end

  def primeiro_img(html)
    Nokogiri::HTML.fragment(html.to_s).at_css("img")&.[]("src")
  end

  # ── Importação ─────────────────────────────────────────────────────────────

  def importar_item(item)
    titulo = item.titulo.to_s.squish
    return false if titulo.length < 5

    link        = resolver_url(item.link)
    external_id = (item.guid.presence || link).to_s.strip.truncate(255)
    return false if external_id.blank?
    return false if @feed.articles.exists?(external_id: external_id)
    return false if link.present? && Article.where(fonte_url: link).exists?

    conteudo = sanitizar(item.conteudo)
    return false if conteudo.blank?

    artigo = Article.new(
      titulo:       titulo.truncate(200, omission: "…"),
      resumo:       montar_resumo(item),
      status:       @feed.publicar_automaticamente? ? :publicado : :aguardando_revisao,
      publicado_em: item.publicado_em || Time.current,
      category:     categoria_para(item),
      author:       autor,
      feed_source:  @feed,
      external_id:  external_id,
      fonte_nome:   @feed.nome,
      fonte_url:    link
    )
    artigo.conteudo = conteudo
    artigo.save!

    aplicar_tags(artigo, item)
    anexar_imagem(artigo, resolver_url(item.imagem_url)) if @feed.importar_imagem?

    true
  end

  def montar_resumo(item)
    texto = item.resumo.presence || item.conteudo
    ActionView::Base.full_sanitizer.sanitize(texto.to_s).to_s.squish.truncate(500, omission: "…")
  end

  def categoria_para(item)
    nomes = Array(item.categorias).map { |nome| nome.to_s.squish }.reject(&:blank?)
    if nomes.any?
      encontrada = Category.where("LOWER(nome) IN (?)", nomes.map(&:downcase)).first
      return encontrada if encontrada
    end
    @feed.category
  end

  def aplicar_tags(artigo, item)
    nomes = Array(item.categorias).map { |nome| nome.to_s.squish }.reject(&:blank?).uniq.first(5)
    return if nomes.empty?

    artigo.tags = nomes.map { |nome| Tag.find_or_create_by!(nome: nome) }
  rescue => e
    Rails.logger.warn("[FeedSyncService:#{@feed.id}] tags: #{e.message}")
  end

  def autor
    @autor ||= @feed.author || User.pode_publicar.order(:id).first || User.order(:id).first
  end

  def sanitizar(html)
    limpo = Rails::Html::SafeListSanitizer.new.sanitize(
      html.to_s,
      tags: TAGS_PERMITIDAS,
      attributes: ATRIBUTOS_PERMITIDOS
    )
    fragmento = Nokogiri::HTML.fragment(limpo)
    # A primeira imagem do conteúdo vira a capa; as demais seriam hotlinks
    # para o site de origem, então saem do corpo da matéria.
    fragmento.css("img").remove
    fragmento.to_html.strip
  end

  # ── Imagem ────────────────────────────────────────────────────────────────

  def anexar_imagem(artigo, url)
    return if url.blank?

    imagem = baixar_imagem(url)
    return if imagem.nil?

    artigo.imagem_capa_file.attach(
      io: StringIO.new(imagem[:corpo]),
      filename: imagem[:filename],
      content_type: imagem[:content_type]
    )
  rescue => e
    Rails.logger.warn("[FeedSyncService:#{@feed.id}] imagem #{url}: #{e.message}")
  end

  def baixar_imagem(url)
    corpo, tipo = requisitar(url, limite_bytes: MAX_IMAGE_BYTES, timeout_leitura: 20)

    if tipo.blank? || tipo == "application/octet-stream"
      tipo = Marcel::MimeType.for(StringIO.new(corpo), name: File.basename(URI.parse(url).path))
    end
    return nil unless ALLOWED_IMAGE_TYPES.include?(tipo)

    extensao = { "image/jpeg" => "jpg", "image/png" => "png",
                 "image/webp" => "webp", "image/gif" => "gif" }.fetch(tipo, "jpg")

    { corpo: corpo, content_type: tipo, filename: "capa-feed.#{extensao}" }
  rescue => e
    Rails.logger.warn("[FeedSyncService:#{@feed.id}] download de imagem #{url}: #{e.message}")
    nil
  end

  # ── HTTP ──────────────────────────────────────────────────────────────────

  def requisitar(url, limite_bytes:, timeout_leitura:)
    uri = URI.parse(url.to_s)
    raise "URL inválida" unless uri.is_a?(URI::HTTP) && uri.host.present?
    raise "URL não permitida" unless host_permitido?(uri.host)

    (MAX_REDIRECTS + 1).times do
      resposta = Net::HTTP.start(
        uri.host, uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: 10,
        read_timeout: timeout_leitura
      ) do |http|
        requisicao = Net::HTTP::Get.new(uri.request_uri)
        requisicao["User-Agent"] = USER_AGENT
        requisicao["Accept"] = "*/*"
        http.request(requisicao)
      end

      case resposta
      when Net::HTTPSuccess
        corpo = resposta.body.to_s
        raise "Resposta maior que o limite permitido" if corpo.bytesize > limite_bytes
        return [ corpo, resposta["Content-Type"].to_s.split(";").first.to_s.strip.downcase.presence ]
      when Net::HTTPRedirection
        destino = resposta["location"].to_s
        raise "Redirecionamento sem destino" if destino.blank?
        uri = URI.join(uri.to_s, destino)
        raise "Redirecionamento para URL não permitida" unless uri.is_a?(URI::HTTP) && host_permitido?(uri.host)
      else
        raise "O servidor respondeu HTTP #{resposta.code}"
      end
    end

    raise "Muitos redirecionamentos"
  rescue URI::InvalidURIError
    raise "URL inválida"
  end

  def normalizar_texto(corpo, charset)
    if charset.present?
      codificacao = Encoding.find(charset) rescue nil
      return corpo.force_encoding(codificacao).encode("UTF-8", invalid: :replace, undef: :replace) if codificacao
    end
    corpo
  end

  def host_permitido?(host)
    enderecos = Resolv.getaddresses(host.to_s)
    return false if enderecos.empty?

    enderecos.all? do |endereco|
      ip = IPAddr.new(endereco)
      !ip.private? && !ip.loopback? && !ip.link_local?
    end
  rescue
    false
  end

  def resolver_url(candidato)
    return nil if candidato.blank?

    URI.join(@feed.url, candidato.to_s.strip).to_s
  rescue URI::Error
    nil
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  def texto(node)
    node&.text.to_s.strip
  end

  def parse_data(valor)
    return nil if valor.blank?

    Time.parse(valor.to_s)
  rescue ArgumentError
    nil
  end
end
