require 'ferret'

module FerretMixin
  module Acts
    module Searchable
      
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        include Ferret
        include Ferret::Search # Odd things get doubly-loaded if you don't include this...
        
        def acts_as_searchable(options = {})
          class_eval do
             include FerretMixin::Acts::Searchable::InstanceMethods
             
             after_destroy :ferret_destroy
             @@ferret_index = {}
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
          
          logger.debug("Search: #{query.to_s}")
          ids = []
          count = ferret_index.search_each(query, options) do |doc, score|
            ids << ferret_index[doc]["id"]
          end
          
          return get_results(ids), count
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
        def ferret_search_date_location(q, date, lat, long, radius, options = {})
          query = basic_ferret_query(q, options)
          
          if not date.nil?
            if options[:exact_date]
              query << Search::BooleanClause.new(Search::TermQuery.new(Index::Term.new("date", indexable_date(date))), Search::BooleanClause::Occur::MUST)
            else
              query << Search::BooleanClause.new(Search::RangeQuery.new("date", indexable_date(date), nil, true, false), Search::BooleanClause::Occur::MUST)
            end
            
            # Sort by date, then relevence
            date_sort = SortField.new("date", {:sort_type => SortField::SortType::INTEGER})
            if options[:sort].nil?
              options[:sort] = [date_sort, SortField::FIELD_SCORE]
            else
              options[:sort] = [options[:sort], date_sort, SortField::FIELD_SCORE]
            end
          elsif options[:sort]
            options[:sort] = [options[:sort], SortField::FIELD_SCORE]
          end
          
          if lat and long and radius
            location_filter = LocationFilter.new(self.class_name.downcase, lat, long, radius)
            options[:filter] = location_filter
          end
          
          logger.debug("Search by date and location: #{query.to_s}, #{options[:sort]}")
          ids = []
          count = ferret_index.search_each(query, options) do |doc, score|
            ids << ferret_index[doc]["id"]
          end
          
           return get_results(ids), count
        end
        
        def ferret_index
          dir = "#{RAILS_ROOT}/db/tb.index/#{self.class_name.downcase}"
          if @@ferret_index[self.class_name.downcase].nil?
            Dir.mkdir(dir) unless File.directory?(dir) or File.symlink?(dir)
          end
          
          @@ferret_index[self.class_name.downcase] ||= Ferret::Index::Index.new(
                                                     :key => ["id"],
                                                     :path => dir,
                                                     :auto_flush => true,
                                                     :create_if_missing => true)                                 
        end
        
        IGNORED_STRINGS = [','] unless const_defined?('IGNORED_STRINGS')
        
        # Set up a basic query
        def basic_ferret_query(q, options = {})
          q = q.strip.downcase
          q = "*" if q.nil? or q == ""
          
          IGNORED_STRINGS.each { |str| q.gsub!(str, ' ') }
          
          query = Search::BooleanQuery.new
          if q != "*"
            options[:analyzer] = Ferret::Analysis::StandardAnalyzer.new
            query_parser = QueryParser.new(["name", "contents"], options)
            
            # Parse the query provided by the user
            query << Search::BooleanClause.new(query_parser.parse(q), Search::BooleanClause::Occur::MUST)
          end
          
           # Add extra conditions
          if options[:conditions]
            options[:conditions].each do |term, condition|
              query_parser = QueryParser.new([term], options)
              query << Search::BooleanClause.new(query_parser.parse(condition), Search::BooleanClause::Occur::MUST)
            end
          end
            
          # Restrict the query to items of this class
          query << Search::BooleanClause.new(Search::TermQuery.new(Index::Term.new("ferret_class", self.class_name.downcase)), Search::BooleanClause::Occur::MUST)
          return query
        end
        
        def indexable_date(date)
          Utils::DateTools.time_to_s(date, Utils::DateTools::Resolution::DAY)
        end
        
        def indexable_date_and_time(date)
          Utils::DateTools.time_to_s(date, Utils::DateTools::Resolution::MINUTE)
        end
        
        protected
        
        def get_results(ids)
          return [] if ids.empty?
          
          where = "where id in (#{ids.join(',')})"
          order = "order by field(id, " + ids.map { |id| "'#{id}'" }.join(',') + ")"
          sql = "select * from #{self.table_name} #{where} #{order}"
          
          self.find_by_sql(sql)
        end
      end
    
      module InstanceMethods
        include Ferret
        
        # Useful for saving the object without reindexing it, which can be expensive
        # Only useful when automatic saving is enabled.
        def save_without_indexing
          @skip_indexing = true
          self.save
          @skip_indexing = false
        end
        
        def ferret_save
          return if @skip_indexing

          doc = Ferret::Document::Document.new
          
          # Index common fields
          doc << Ferret::Document::Field.new("id", self.id, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
          doc << Ferret::Document::Field.new("ferret_class", self.class.name.downcase, 
                                             Document::Field::Store::YES,
                                             Document::Field::Index::UNTOKENIZED)
                                             
          if respond_to?(:name)                                   
            doc << Ferret::Document::Field.new("name", 
                                               self.name, 
                                               Document::Field::Store::YES, 
                                               Document::Field::Index::TOKENIZED,
                                               Document::Field::TermVector::NO,
                                               false,
                                               2.0)
            
            if respond_to?(:short_name)   
              # Untokenized short name for sorting                                   
              doc << Ferret::Document::Field.new("sort_name", 
                                               self.short_name, 
                                               Document::Field::Store::NO, 
                                               Document::Field::Index::UNTOKENIZED)
            end
          end
          
          if respond_to?(:created_on)
            doc << Ferret::Document::Field.new("created_on", 
                                               self.class.indexable_date_and_time(self.created_on), 
                                               Document::Field::Store::YES, 
                                               Document::Field::Index::UNTOKENIZED)
          end
          
          if respond_to?(:popularity)
            popularity = self.popularity
            doc << Document::Field.new("popularity", 
                                       popularity, 
                                       Document::Field::Store::YES, 
                                       Ferret::Document::Field::Index::UNTOKENIZED)
                                       
            # Boost document based on popularity
            # TODO This is not very good. Think of a better way to do this.
            # All this really does is make sure that completely unpopular things are further down the scale.
            doc.boost = 1.3 if popularity > 10
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
          doc << Ferret::Document::Field.new("contents", contents.strip, Ferret::Document::Field::Store::YES, Ferret::Document::Field::Index::TOKENIZED)
          
          # Type-specific fields
          [*self.add_searchable_fields].each { |field| doc << field }
          
          self.class.ferret_index << doc
        end
        
        def ferret_destroy
          self.class.ferret_index.query_delete("+id:#{self.id}")
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
