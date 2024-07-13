Jekyll::Hooks.register :documents, :post_render do |doc|
  doc.output.gsub! /<table>/, '<div class="table-wrapper" markdown="block"><table>'
  doc.output.gsub! /<\/table>/, '</table></div>'
end