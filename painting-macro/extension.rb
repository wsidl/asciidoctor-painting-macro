require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include ::Asciidoctor

class PaintingBlockMacroProcessor < Extensions::BlockMacroProcessor
  use_dsl
  named :painting
  name_positional_attributes 'title', 'artist', 'location', 'medium', 'size', 'year', 'source', 'note'

  def initialize(name=nil, config={})
    super name, config
    @count = 0
  end

  def process(parent, target, attrs)
    title = attrs['title']
    artist = attrs['artist']
    #create_image_block parent, title, {}
    content = ""
    @count += 1
    imgloc = (parent.document.attr? 'imagesdir') ? "#{parent.document.attr 'imagesdir'}/" : ''
    case parent.document.backend
    when 'html5' then
      image = "<img src=\"#{imgloc}#{target}\">"
      html = "<a name=\"#{attrs['id']}\"></a><figure class=\"paintingSect\">"
      cap1 = "<figcaption class=\"paintingMain\"><span class=\"paintingPrefix\">Painting #{@count}</span>: <span class=\"paintingTtl\">\"#{title}\"</span></figcaption><figcaption class=\"paintingArt\">#{artist}</figcaption>"
      cap2 = (attrs.has_key? 'location') ? "<figcaption class=\"paintingLoc\">#{attrs['location']}</figcaption>" : ''
      cap3 = (attrs.has_key? 'medium') ? "<figcaption class=\"paintingMed\">#{attrs['medium']}</figcaption>" : ''
      cap4 = (attrs.has_key? 'size') ? "<figcaption class=\"paintingSuz\">#{attrs['size']}</figcaption>" : ''
      cap5 = (attrs.has_key? 'source') ? "<figcaption class=\"paintingSrc\">#{attrs['source']}</figcaption>" : ''
      cap6 = (attrs.has_key? 'note') ? "<figcaption class=\"paintingOth\">#{attrs['note']}</figcaption>" : ''
      content = "#{html}#{image}<div class=\"paintingCaptions\">#{cap1}#{cap2}#{cap3}#{cap4}#{cap5}#{cap6}</div></figure>"
    end
    attrs[:index] = @count
    attrs["role"] = "painting"
    create_pass_block parent, content, attrs, {"subs" => nil, }
  end

end

class PaintingTOCTreeprocessor < Extensions::Treeprocessor

  def process document
    tocpaintings = []
    tocfigures = []
    mask = ""
    figid = 0
    case document.backend
    when 'html5' then
      document.find_by context: :image do |block|
        unless block.title == nil
          figid += 1
          block.id = figid
          tocfigures.push("<li><a href=\"#figure_#{figid}\">Figure #{figid}: #{block.title}</a></li>")
        end
      end
      document.find_by context: :pass, role: "painting" do |block|
        year = " (#{block.attributes['year']})" unless block.attributes['year'] == nil
        tocpaintings.push("<li><a href=\"##{block.id}\">Painting #{block.attributes[:index]}: \"#{block.title}\"#{year}</a></li>")
      end
      tocfigures = "<div id=\"toc\" class=\"toc\"><ul>\n#{tocfigures.join("\n")}</ul></div>"
      tocpaintings = "<div id=\"toc\" class=\"toc\"><ul>\n#{tocpaintings.join("\n")}</ul></div>"
    end
    document.find_by(id: "toc-paintings") {|b| b << Block.new(b, :pass, :source => tocpaintings)}
    document.find_by(id: "toc-figures") {|b| b << Block.new(b, :pass, :source => tocfigures)}
  end
end
