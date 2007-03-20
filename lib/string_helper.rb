# String helpers and utilities
class StringHelper

  # NOTE This is all taken from Redcloth. See COPYING.redcloth
  # The idea for this was taken off the web...
  BASIC_TAGS = {
        'a' => ['href', 'title'],
        'img' => ['src', 'alt', 'title','align','width','height','border','class'],
        'br' => [],
        'i' => nil,
        'u' => nil,
        'b' => nil,
        'pre' => nil,
        'kbd' => nil,
        'code' => ['lang'],
        'cite' => nil,
        'strong' => nil,
        'em' => nil,
        'ins' => nil,
        'sup' => nil,
        'sub' => nil,
        'del' => nil,
        'table' => nil,
        'tr' => nil,
        'td' => ['colspan', 'rowspan'],
        'th' => nil,
        'ol' => nil,
        'ul' => nil,
        'li' => nil,
        'p' => nil,
        'h1' => nil,
        'h2' => nil,
        'h3' => nil,
        'h4' => nil,
        'h5' => nil,
        'h6' => nil,
        'blockquote' => ['cite']
    } unless const_defined?("BASIC_TAGS")
    
    STRUCTURE_TAGS = {
        'a' => ['href', 'title'],
        'br' => [],
        'table' => nil,
        'tr' => nil,
        'td' => ['colspan', 'rowspan'],
        'th' => nil,
        'ol' => nil,
        'ul' => nil,
        'li' => nil,
        'p' => nil,
        'h1' => nil,
        'h2' => nil,
        'h3' => nil,
        'h4' => nil,
        'h5' => nil,
        'h6' => nil,
        'html' => nil,
        'blockquote' => ['cite']
    } unless const_defined?("STRUCTURE_TAGS")
    

    def self.clean_html!( text, tags = BASIC_TAGS )
        text.gsub!( /<!\[CDATA\[/, '' )
        text.gsub!( /<(\/*)(\w+)([^>]*)>/ ) do
            raw = $~
            tag = raw[2].downcase
            if tags.has_key? tag
                pcs = [tag]
                pcs << "rel=\"nofollow\"" if tag=='a'
                tags[tag].each do |prop|
                    ['"', "'", ''].each do |q|
                        q2 = ( q != '' ? q : '\s' )
                        if raw[3] =~ /#{prop}\s*=\s*#{q}([^#{q2}]+)#{q}/i
                            attrv = $1
                            next if tag!='img' and prop == 'src' and attrv !~ /^http/
                            pcs << "#{prop}=\"#{$1.gsub('"', '\\"')}\""
                            break
                        end
                    end
                end if tags[tag]
                "<#{raw[1]}#{pcs.join " "}>"
            else
                " "
            end
        end
    end

    def self.clean_html( text, tags = BASIC_TAGS)
      str = text.dup
      clean_html!(str,tags)
      str
    end

    def clean_html( text, tags = BASIC_TAGS )
      self.class.clean_html!(text,tags)
    end
    
    # Cleans up string to be included in the url.
    # Returns cleaned, new string or nil iff nil is passed
    def self.urlize(str)
      return nil if str.nil?
      url = ""
    
      # Convert spaces to _
      url = str.gsub(/\s+/, '_')
      # Pull out non-word chars
      url.gsub!(/[()'\.]/, '')
    
      return url
  end
end