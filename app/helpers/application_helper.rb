module ApplicationHelper
  def render_markdown(text)
    return "" if text.blank?

    html = text.to_s
    html = html.gsub(/\*\*\*(.+?)\*\*\*/m, '<strong><em>\1</em></strong>')
    html = html.gsub(/\*\*(.+?)\*\*/m, '<strong>\1</strong>')
    html = html.gsub(/\*(.+?)\*/m, '<em>\1</em>')
    html = html.gsub(/\[(.+?)\]\((.+?)\)/, '<a href="\2">\1</a>')
    html = html.gsub(/\n/, '<br>')

    raw(html)
  end
end
