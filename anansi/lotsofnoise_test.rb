require 'tidy'
require 'net/http'
require 'rexml/document'
include REXML

# Should add methods to REXML::Element
def find_element(root, content)
  root.elements.each("//") do |elem|
    next if elem.text.nil?
    return elem if elem.texts.join(" ").include?(content)
  end
  
  return nil
end

def find_parent(doc, child, tag)
  while child != doc.root
    parent = child.parent
    return parent if parent.name == tag
    child = parent
  end
end

def recursive_text(elem)
  text = ''
  elem.children.each do |e|
    if e.class == Text
      text << e.to_s
    else
      text << recursive_text(e)
    end
  end
  
  return text
end

# Point ruby at the tidy dll
Tidy.path = 'c:\\dev\\tidy\\bin\\tidy.dll'

# Almost works with both... just need to clean out unnecessary HTML
#html = File.new('anansi/lotsofnoise.test.html').read
html = File.new('anansi/ohmyrockness.test.html').read


# Parse and convert to xml
xml = Tidy.open(:show_warnings => true) do |tidy|
  tidy.options.output_xml = true
  tidy.clean(html)
end

# Get rexml doc
doc = Document.new(xml)

# Find elem with magic text
elem = find_element(doc, "$8")
p "Found: " + elem.texts.join(" ")

# Find containing table and print each cell
table = find_parent(doc, elem, "table")
p table
table.elements.each("tr") do |row|
  puts "\n*** Here is a potential show:"
  row.elements.each("td") do |cell|
    puts "-   " + recursive_text(cell)
  end
end



