module ApplicationHelper
  include Pagy::Frontend

  def pagy_nav(pagy, id: nil, aria_label: nil, **vars)
    id_attr = id ? %( id="#{id}") : ""
    a = pagy_anchor(pagy, **vars)

    html = %(<nav#{id_attr} class="flex items-center gap-1" aria-label="Paginação">)

    # Previous
    if (p_prev = pagy.prev)
      html << a.(p_prev, "‹", classes: "px-3 py-1.5 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg transition-colors", aria_label: "Página anterior")
    else
      html << %(<span class="px-3 py-1.5 text-sm text-gray-300 select-none" aria-disabled="true">‹</span>)
    end

    pagy.series(**vars).each do |item|
      html << case item
              when Integer
                a.(item, pagy.label_for(item), classes: "px-3 py-1.5 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg transition-colors")
              when String
                %(<span class="px-3 py-1.5 text-sm font-semibold bg-blue-600 text-white rounded-lg" aria-current="page">#{pagy.label_for(item)}</span>)
              when :gap
                %(<span class="px-2 py-1.5 text-sm text-gray-400">…</span>)
              end
    end

    # Next
    if (p_next = pagy.next)
      html << a.(p_next, "›", classes: "px-3 py-1.5 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg transition-colors", aria_label: "Próxima página")
    else
      html << %(<span class="px-3 py-1.5 text-sm text-gray-300 select-none" aria-disabled="true">›</span>)
    end

    html << "</nav>"
    html.html_safe
  end
end
