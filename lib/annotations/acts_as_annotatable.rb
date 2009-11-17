# ActsAsAnnotatable
module Annotations
  module Acts #:nodoc:
    module Annotatable #:nodoc:

      def self.included(base)
        base.send :extend, ClassMethods 
      end

      module ClassMethods
        def acts_as_annotatable
          has_many :annotations, 
                   :as => :annotatable, 
                   :dependent => :destroy, 
                   :order => 'created_at ASC'
                   
          send :extend, SingletonMethods
          send :include, InstanceMethods
        end
      end
      
      # Class methods added to the model that has been made acts_as_annotatable (ie: the mixin annotatable type).
      module SingletonMethods
        # Helper finder to get all objects of the mixin annotatable type that have the specified attribute name and value.
        #
        # NOTE (1): both the attribute name and the value will be treated case insensitively.
        def with_annotations_with_attribute_name_and_value(attribute_name, value)
          return [ ] if attribute_name.blank? or value.nil?
          
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          anns = Annotation.find(:all,
                                 :joins => :attribute,
                                 :conditions => { :annotatable_type => obj_type, 
                                                  :annotation_attributes =>  { :name => attribute_name.strip.downcase }, 
                                                  :value => value.strip.downcase })
                                                  
          return anns.map{|a| a.annotatable}
        end
        
        # Helper finder to get all annotations for an object of the mixin annotatable type with the ID provided.
        # This is the same as object.annotations with the added benefit that the object doesnt have to be loaded.
        # E.g: Book.find_annotations_for(34) will give all annotations for the Book with ID 34.
        def find_annotations_for(id)
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Annotation.find(:all,
                          :conditions => { :annotatable_type =>  obj_type, 
                                           :annotatable_id => id },
                          :order => "created_at DESC")
        end
        
        # Helper finder to get all annotations for all objects of the mixin annotatable type, by the source specified.
        # E.g: Book.find_annotations_by('User', 10) will give all annotations for all Books by User with ID 10. 
        def find_annotations_by(source_type, source_id)
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Annotation.find(:all,
                          :conditions => { :annotatable_type =>  obj_type, 
                                           :source_type => source_type,
                                           :source_id => source_id },
                          :order => "created_at DESC")
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        
        # Provides a default implementation to get the display name for 
        # an annotatable object, that can be overrided.
        def annotatable_name
          %w{ preferred_name display_name title name }.each do |w|
            return eval("self.#{w}") if self.respond_to?(w)
          end
          return "#{self.class.name}_#{self.id}"
        end
        
        # Helper method to get latest annotations
        def latest_annotations(limit=nil)
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self.class).to_s
          
          Annotation.find(:all,
                          :conditions => { :annotatable_type =>  obj_type, 
                                           :annotatable_id => self.id },
                          :order => "created_at DESC",
                          :limit => limit)
        end
        
        # Finder to get annotations with a specific attribute.
        # The input parameter is the attribute name 
        # (MUST be a String representing the attribute's name).
        def annotations_with_attribute(attrib)
          return [] if attrib.blank?
          
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self.class).to_s
          
          Annotation.find(:all,
                          :joins => :attribute,
                          :conditions => { :annotatable_type => obj_type,
                                           :annotatable_id => self.id,
                                           :annotation_attributes =>  { :name => attrib.strip.downcase } },
                          :order => "created_at DESC")
        end
        
        # Same as the {obj}.annotations_with_attribute method (above) but 
        # takes in an array for attribute names to look for.
        #
        # NOTE (1): the argument to this method MUST be an Array of Strings.
        def annotations_with_attributes(attribs)
          return [] if attribs.blank?
          
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self.class).to_s
          
          Annotation.find(:all,
                          :joins => :attribute,
                          :conditions => { :annotatable_type => obj_type,
                                           :annotatable_id => self.id,
                                           :annotation_attributes =>  { :name => attribs } },
                          :order => "created_at DESC")
        end
        
        # Finder to get annotations with a specific attribute by a specific source.
        #
        # The first input parameter is the attribute name (MUST be a String representing the attribute's name).
        # The second input is the source object.
        def annotations_with_attribute_and_by_source(attrib, source)
          return [] if attrib.blank? or source.nil?
          
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self.class).to_s
          
          Annotation.find(:all,
                          :joins => :attribute,
                          :conditions => { :annotatable_type => obj_type,
                                           :annotatable_id => self.id,
                                           :source_type => source.class.name,
                                           :source_id => source.id,
                                           :annotation_attributes =>  { :name => attrib.strip.downcase } },
                          :order => "created_at DESC")
        end
        
        # Finder to get all annotations on this object excluding those that
        # have the attribute names specified.
        #
        # NOTE (1): the argument to this method MUST be an Array of Strings.
        # NOTE (2): the returned records will be Read Only.
        def all_annotations_excluding_attributes(attribs)
          return [] if attribs.blank?
          
          obj_type = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self.class).to_s
          
          Annotation.find(:all,
                          :joins => :attribute,
                          :conditions => [ "`annotations`.`annotatable_type` = ? AND `annotations`.`annotatable_id` = ? AND `annotation_attributes`.`name` NOT IN (?)",
                                           obj_type,
                                           self.id,
                                           attribs ],
                          :order => "`annotations`.`created_at` DESC")
        end
        
        # Returns the number of annotations on this annotatable object by the source type specified.
        # "all" (case insensitive) can be provided to get all annotations regardless of source type.
        # E.g.: book.count_annotations_by("User") or book.count_annotations_by("All")
        def count_annotations_by(source_type_in)
          if source_type_in == nil || source_type_in.downcase == "all"
            return self.annotations.count
          else
            return self.annotations.count(:conditions => { :source_type => source_type_in })  
          end
        end
        
        # Use this method to create many annotations from a Hash of data.
        # Arrays for Hash values will be converted to multiple annotations.
        # Blank values (nil or empty string) will be ignored and thus annotations
        # will not be created for them.
        #
        # Returns an array of Annotation objects of the annotations that were
        # successfully created.
        #
        # Code example:
        # -------------
        # data = { "tag" => [ "tag1", "tag2", "tag3" ], "description" => "This is a book" }
        # book.create_annotations(data, current_user)
        def create_annotations(annotations_data, source)
          anns = [ ]
          
          annotations_data.each do |attrib, val|
            unless val.blank?
              if val.is_a? Array
                val.each do |val_inner|
                  unless val_inner.blank?
                    ann = self.annotations << Annotation.new(:attribute_name => attrib, 
                                                 :value => val_inner, 
                                                 :source_type => source.class.name, 
                                                 :source_id => source.id)
                    
                    unless ann.nil? || ann == false
                      anns << ann
                    end
                  end
                end
              else
                ann = self.annotations << Annotation.new(:attribute_name => attrib, 
                                             :value => val, 
                                             :source_type => source.class.name, 
                                             :source_id => source.id)
                
                unless ann.nil? || ann == false
                  anns << ann
                end
              end
            end
          end
          
          return anns
        end
      end
      
    end
  end
end
