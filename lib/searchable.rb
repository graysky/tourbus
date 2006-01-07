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

             after_save :ferret_save
             after_destroy :ferret_destroy
             @@ferret_index = nil
          end
        end
        
        # Simplest search method. Returns an array of objects matching the query.
        # query is a string or a ferret Query object.
        #
        # Returns an array where the first element is the results, and the second
        # is the total number of hits
        #
        # Options:
        # filter:	Filters docs from the search result
        # first_doc:	The index in the results of the first doc retrieved. Default is 0
        # num_docs:	The number of results returned. Default is 10
        # sort:	An array of SortFields describing how to sort the results. 
        def ferret_search(q, options = {})
          query = basic_ferret_query(q, options)
          
          #if not date.nil?
            #query << Search::BooleanClause.new(Search::RangeQuery.new("date", Utils::DateTools.time_to_s(date), nil, false, false), Search::BooleanClause::Occur::MUST)
          #end
          
          logger.debug("Search: #{query.to_s}")
          ret = []
          count = ferret_index.search_each(query, options) do |doc, score|
            # This is not very efficient, but you can't ask for all the records
            # at the same time if you want to keep ordering by score.
            # Luckily, there should never be that many items as search results.
            # TODO Evaluate this. Another option is to use the FIELD function:
            # order by field(id, '3','1','4','2'), for example
            ret << self.find(ferret_index[doc]["id"])
          end
          
          return ret, count
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
        # filter:	Filters docs from the search result
        # first_doc:	The index in the results of the first doc retrieved. Default is 0
        # num_docs:	The number of results returned. Default is 10
        # sort:	An array of SortFields describing how to sort the results.
        def ferret_search_date_location(q, date, lat, long, radius, options = {})
          query = basic_ferret_query(q, options)
          
          if not date.nil?
            query << Search::BooleanClause.new(Search::RangeQuery.new("date", Utils::DateTools.time_to_s(date), nil, true, false), Search::BooleanClause::Occur::MUST)
            
            # Sort by date, then relevence
            date_sort = SortField.new("date", {:sort_type => SortField::SortType::INTEGER})
            options[:sort] = [date_sort, SortField::FIELD_SCORE]
          end
          
          if lat and long and radius
            location_filter = LocationFilter.new(self.class_name.downcase, lat, long, radius)
            options[:filter] = location_filter
          end
          
          logger.debug("Search by date and location: #{query.to_s}")
          ret = []
          count = ferret_index.search_each(query, options) do |doc, score|
            # This is not very efficient, but you can't ask for all the records
            # at the same time if you want to keep ordering by score.
            # Luckily, there should never be that many items as search results.
            # TODO Evaluate this. Another option is to use the FIELD function:
            # order by field(id, '3','1','4','2'), for example
            ret << self.find(ferret_index[doc]["id"])
          end
          
          return ret, count
        end
        
        def ferret_index
          @@ferret_index ||= Ferret::Index::Index.new(:key => ["id", "ferret_class"],
                                                     :path => "#{RAILS_ROOT}/db/tb.index",
                                                     :auto_flush => true,
                                                     :create_if_missing => true)                                            
        end
        
        # Set up a basic query
        def basic_ferret_query(q, options = {})
          query_parser = QueryParser.new(["name", "contents"])
          query = Search::BooleanQuery.new
          
          # Parse the query provided by the user
          query << Search::BooleanClause.new(query_parser.parse(q), Search::BooleanClause::Occur::MUST)
          
          # Restrict the query to items of this class
          query << Search::BooleanClause.new(Search::TermQuery.new(Index::Term.new("ferret_class", self.class_name.downcase)), Search::BooleanClause::Occur::MUST)
          return query
        end
      end
    
      module InstanceMethods
        include Ferret
        
        # Useful for saving the object without reindexing it, which can be expensive
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
                                               Document::Field::Index::TOKENIZED)
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
        
        
        protected
        
        # Override for type-specific fields
        def add_searchable_fields
          []
        end
        
        # Override for type-specific contents
        def add_searchable_contents
          ""
        end
        
        def ferret_destroy
          self.class.ferret_index.query_delete("+id:#{self.id} +ferret_class:#{self.class.name.downcase}")
        end
      end
      
    end
  end
end
