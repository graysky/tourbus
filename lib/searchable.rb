require 'ferret'

module FerretMixin
  module Acts
    module Searchable
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
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
        # Options:
        # filter:	Filters docs from the search result
        # first_doc:	The index in the results of the first doc retrieved. Default is 0
        # num_docs:	The number of results returned. Default is 10
        # sort:	An array of SortFields describing how to sort the results. 
        def ferret_search(query, options = {})
          ret = []
          ferret_index.search_each(query, options) do |doc, score|
            # This is not very efficient, but you can't ask for all the records
            # at the same time if you want to keep ordering by score.
            # Luckily, there should never be that many items as search results.
            # TODO Evaluate this. Another option is to use the FIELD function:
            # order by field(id, '3','1','4','2'), for example
            ret << self.find(ferret_index[doc]["id"])
          end
          
          return ret
        end
        
        def ferret_index
          @@ferret_index ||= Ferret::Index::Index.new(:key => ["id", "ferret_class"],
                                                     :path => "#{RAILS_ROOT}/db/tb.index",
                                                     :auto_flush => true,
                                                     :create_if_missing => true)                                            
        end
      end
    
      module InstanceMethods
        
        def ferret_save
          
          doc = Ferret::Document::Document.new
          
          # Index common fields
          doc << Ferret::Document::Field.new("id", self.id, Ferret::Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
          doc << Ferret::Document::Field.new("ferret_class", self.class.name, 
                                             Ferret::Document::Field::Store::YES,
                                             Ferret::Document::Field::Index::UNTOKENIZED,
                                             Ferret::Document::Field::TermVector::NO,
                                             :binary => false,
                                             :boost => 1.5)
          if respond_to?(:name)                                   
            doc << Ferret::Document::Field.new("name", self.name, Ferret::Document::Field::Store::YES, Ferret::Document::Field::Index::TOKENIZED)
          end
          
          # Index all commonly searched info as an aggregated content string
          contents = ""
          if respond_to?(:name)
            contents << self.name + " "
          end
          
          if respond_to?(:tag_names)
            contents << self.tag_names.join(" ")
          end
          
          doc << Ferret::Document::Field.new("contents", contents, Ferret::Document::Field::Store::YES, Ferret::Document::Field::Index::TOKENIZED)
          
          # TODO User-defined
          
          self.class.ferret_index << doc
        end
        
        def ferret_destroy
          self.class.ferret_index.query_delete("+id:#{self.id} +ferret_class:#{self.class.name}")
        end
      end
      
    end
  end
end
