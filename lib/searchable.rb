require 'builder'
require 'net/http'
require 'uri'
require 'open-uri'

module FerretMixin
  module Acts
    module Searchable
         
      def self.append_features(base)
        super
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        
        def solr_server
          @@SOLR_SERVER
        end
        
        def solr_port
          @@SOLR_PORT
        end
        
        def acts_as_searchable(options = {})
          class_eval do
             include FerretMixin::Acts::Searchable::InstanceMethods
             
             after_destroy :ferret_destroy
             
             @@SOLR_SERVER = "localhost"
             @@SOLR_PORT = "8983"
          end
        end
        
        def index_all(options = {})
          chunk_size = 500
          offset = 0
          count = self.count
          
          options[:limit] = chunk_size
          
          while offset < count
            options[:offset] = offset
             
            doc = ""
            xml = Builder::XmlMarkup.new(:target => doc)
            xml.add do
              self.find(:all, options).each do |obj|
                obj.get_doc(xml)
              end
            end
            
            update_doc(doc)
            
            offset += chunk_size
          end
          
          commit(:optimize => true)
        end
        
        def update_doc(doc)
          Net::HTTP.start(solr_server, solr_port) do |http|
            http.post("/solr/update", doc)
          end
        end
        
        def commit(options = {})
          Net::HTTP.start(solr_server, solr_port) do |http|
            http.post("/solr/update", "<commit/>")
            http.post("/solr/update", "<optimize/>") if options[:optimize]
          end
        end
        
        
        # Simplest search method. Returns an array of objects matching the query.
        # query is a string or a ferret Query object.
        #
        # Returns an array where the first element is the results, and the second
        # is the total number of hits
        #
        # Options:
        # filter:  Filters docs from the search result
        # first_doc:  The index in the results of the first doc retrieved. Default is 0
        # num_docs:  The number of results returned. Default is 10
        # sort:  An array of SortFields describing how to sort the results. 
        def ferret_search(q, options = {})
          query = basic_ferret_query(q, options)
          
          if options[:sort]
            add_sorts(query, options[:sort])
          end
          
          do_query(query, options)
        end
        
        # Search using the given query but only include results with a date newer than
        # the given date, and only include results within the given radius (in miles) 
        # of the given coordinate.
        #
        # Returns an array where the first element is the results, and the second
        # is the total number of hits
        #
        # A date search requires a "date" field, the location search requires a "latitude"
        # and "longitude" field. 
        # 
        # If date is nil then the date search will be ignored for this query.
        # If latitude, longitude radius is nil location search will be ignored for this query.
        # 
        # Results will first be ordered by date (if applicable), then relevance.
        #
        # Options:
        # filter:  Filters docs from the search result
        # first_doc:  The index in the results of the first doc retrieved. Default is 0
        # num_docs:  The number of results returned. Default is 10
        # sort:  An array of SortFields describing how to sort the results.
        # exact_date: Only results on the given date.
        # conditions: A hash of conditions: 'popularity' => '> 0'
        # include: The include argument to ActiveRecord's find methods.
        def ferret_search_date_location(q, date, lat, long, radius, options = {})
          query = basic_ferret_query(q, options)
          
          if not date.nil?
            if options[:exact_date]
              query << " AND date:#{indexable_date(date)}"
            else
              query << " AND date:[#{indexable_date(date)} TO *]"
            end
            
            if options[:sort]
              add_sorts(query, options[:sort])
            end
            
            add_sorts(query, "date asc, score desc")
            
          elsif options[:sort]
            add_sorts(query, options[:sort])
          end
     
          options[:doc_type] = self.class_name.downcase
          options[:lat] = lat
          options[:long] = long
          options[:radius] = radius
          
          logger.debug("Search by date and location: #{query.to_s}, #{options.to_s}")
          do_query(query, options)
        end
        
        IGNORED_STRINGS = [','] unless const_defined?('IGNORED_STRINGS')
        INVALID_CHARS = ['!', '+', '(', ')', '{', '}', '-', '='] unless const_defined?('INVALID_CHARS')
        
        # Set up a basic query
        def basic_ferret_query(q, options = {})
          if q.nil? || q.strip == '*'
            q = ''
          else
            q = q.strip.downcase
          end
          
          query = "ferret_class:#{self.class_name.downcase}"
          if q != ""
            IGNORED_STRINGS.each { |str| q.gsub!(str, ' ') }
            INVALID_CHARS.each { |str| q.gsub!(str, '') }
            
            # Can't end in
            q = q[0...(q.size - 1)] if q.ends_with?('-')
            q.gsub!('-', '') if q.ends_with?('-*')
            
            # A big ole hack for wildcards and quotes. Working around ferret bug.
            #if q.ends_with?('*')
            #  q.gsub!("'", "")
            #  q.gsub!('"', "")
            #end
            
            query << " AND (id:#{q} OR contents:#{q})"
          end
          
           # Add extra conditions
           if options[:conditions]
             options[:conditions].each do |condition|
              query << " AND #{condition}"  
             end
           end
          
          return query
        end
        
        def indexable_date(date)
          date.strftime("%Y%m%d")
        end
        
        protected
        
        def url_options(options)
          str = ""
        
          str << "&rows=#{options[:num_docs]}" if options[:num_docs]
          str << "&start=#{options[:first_doc]}" if options[:first_doc]
          str << "&docType=#{options[:doc_type]}" if options[:doc_type]
          str << "&lat=#{options[:lat]}" if options[:lat]
          str << "&long=#{options[:long]}" if options[:long]
          str << "&radius=#{options[:radius]}" if options[:radius]
          
          str
        end
        
        def add_sorts(query, sorts)
          if query.index(";")
            query << ", " + sorts
          else
            query << ";" + sorts
          end
          
          query
        end
        
        def do_query(query, options = {})
          url = "http://localhost:8983/solr/select?version=2.1&qt=tb&"
          url << "q=#{CGI.escape(query)}"
          url << url_options(options)
          url << "&fl=id&wt=ruby"
          
          results = {}
          open(url) do |f|
            results = eval(f.read)
          end
          
          logger.debug("solr query time: #{results['header']['qtime']}")
          return get_results(results['response']['docs']), results['response']['numFound']
        end
        
        # Use AR get the actual objects from the DB
        def get_results(docs, include = nil)
          return [] if docs.empty?
          
          ids = docs.collect { |doc| doc['id'] }
          
          conditions = "#{self.table_name}.id in (#{ids.join(',')})"
          order = "field(#{self.table_name}.id, " + ids.map { |id| "'#{id}'" }.join(',') + ")"
          
          self.find(:all, :conditions => conditions, :order => order, :include => include)
        end
      end
    
      module InstanceMethods
        
        # Useful for saving the object without reindexing it, which can be expensive
        # Only useful when automatic saving is enabled.
        def save_without_indexing
          @skip_indexing = true
          self.save
          @skip_indexing = false
        end
        
        def ferret_save(options = {})
          return if @skip_indexing
          
          options[:commit] = options[:commit] || true

          doc = ""
          xml = Builder::XmlMarkup.new(:target => doc, :indent => 2)
          xml.add do
            get_doc(xml)
          end

          Net::HTTP.start(self.class.solr_server, self.class.solr_port) do |http|
            http.post("/solr/update", doc)
            
            if options[:commit]
              http.post("/solr/update", "<commit/>")
            end
          end
        end
        
        def get_doc(xml)
          boost = 1.0
          if respond_to?(:popularity) && self.popularity > 10
            boost = 1.5
          end
          
          xml.doc(:boost => boost) do
            # Index common fields
            xml.field(self.class.name.downcase + "-" + self.id.to_s, :name => "key")
            xml.field(self.id, :name => "id")
            xml.field(self.class.name.downcase, :name => "ferret_class")
            
            if respond_to?(:name)
              xml.field(self.name, :name => "name", :boost => 2.0)                                  
            end
            
            if respond_to?(:short_name)
             xml.field(self.short_name, :name => "sort_name") 
            end
            
            if respond_to?(:created_on)
              xml.field(self.created_on.strftime("%Y%m%d"), :name => "created_on")
            end
            
            if respond_to?(:popularity)
              xml.field(self.popularity, :name => "popularity")
            end
            
            # Index all commonly searched info as an aggregated content string
            contents = ""
            if respond_to?(:name)
              contents << self.name + " "
            end
            
            if respond_to?(:tag_names)
              contents << self.tag_names.join(" ")
            end
            
            # Type-specific contents
            contents << " " + self.add_searchable_contents
            xml.field(contents, :name => "contents")
            
            # Type-specific fields
            self.add_searchable_fields(xml)
          end
        end
        
        def ferret_destroy
          Net::HTTP.start(self.class.solr_server, self.class.solr_port) do |http|
            query = "id:#{self.id} AND ferret_class:#{self.class.name.downcase}"
            http.post("/solr/update", "<delete><query>#{query}</query></delete>")
            http.post("/solr/update", "<commit/>")
          end
        end
        
        protected
        
        # Override for type-specific fields
        def add_searchable_fields
          []
        end
        
        # Override for type-specific contents
        def add_searchable_contents
          ""
        end
        
      end
      
    end
  end
end
