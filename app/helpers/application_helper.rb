# app/helpers/application_helper.rb
module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,   # Prevent raw HTML from being rendered
      hard_wrap: true      # Add <br> for line breaks
    )
    options = {
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      lax_spacing: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end
end