module Annotations
  module Config
    # List of attribute name(s) that need the corresponding value to be downcased (made all lowercase).
    # 
    # NOTE: The attribute names specified MUST all be in lowercase.
    @@attribute_names_for_values_to_be_downcased = [ ]
    
    # List of attribute name(s) that need the corresponding value to be upcased (made all uppercase).
    #
    # NOTE: The attribute names specified MUST all be in lowercase.
    @@attribute_names_for_values_to_be_upcased = [ ]
    
    # This defines a hash of attributes, and the characters/strings that need to be stripped (removed) out of values of the attributes specified.
    # Regular expressions can also be used instead of characters/strings.
    # ie: { attribute_name => [ array of characters to strip out ] }    (note: doesn't have to be an array, can be a single string)
    #
    # e.g: { "tag" => [ '"', ','] } or { "tag" => '"' }
    # 
    # NOTE: The attribute name(s) specified MUST all be in lowercase.  
    @@strip_text_rules = { }
    
    # This allows you to specify a different model name for users in the system (if different from the default: "User").
    @@user_model_name = "User"
    
    # This allows you to limit the number of annotations (of specified attribute names) per source per annotatable.
    #
    # Key/value pairs in hash should follow the spec:
    # { attribute_name => max_number_allowed }
    #
    # e.g: { "rating" =>1 } - will only ever allow 1 "rating" annotation per annotatable by each source.
    #
    # NOTE (1): The attribute name(s) specified MUST all be in lowercase.
    @@limits_per_source = { }
    
    # By default, duplicate annotations CANNOT be created (same value for the same attribute, on the same annotatable object, regardless of source). 
    # For example: a user cannot add a description to a specific book that matches an existing description for that book.
    # 
    # This config setting allows exceptions to this rule, on a per attribute basis. 
    # I.e: allow annotations with certain attribute names to have duplicate values (per annotatable).
    #
    # e.g: [ "tag", "rating" ] - allows tags and ratings to have the same value more than once.
    #
    # NOTE (1): The attribute name(s) specified MUST all be in lowercase.
    # NOTE (2): This setting can be used in conjunction with the limits_per_source setting to allow 
    #           duplicate annotations BUT limit the number of annotations (per attribute) per user.
    @@attribute_names_to_allow_duplicates = [ ]
    
    # This allows you to restrict the value for annotations with a specific attribute name.
    #
    # Key/value pairs in the hash should follow the spec:
    # { attribute_name => { :in => array_or_range, :error_message => error_msg_to_show_if_value_not_allowed }
    #
    # e.g: { "rating" => { :in => 1..5, :error_message => "Please provide a rating between 1 and 5" } }
    #
    # NOTE (1): The attribute name(s) specified MUST all be in lowercase.
    # NOTE (2): values will be checked in a case insensitive manner.
    @@value_restrictions = { }

    # This determines what template to use to generate the unique 'identifier' for new AnnotationAttribute objects.
    #
    # String interpolation will be used to place the 'name' of the annotation within the template,
    # in order to generate a unique identifier (usually a URI).
    #
    # This uses the @@attribute_name_transform_for_identifier defined below when performing the substitution.
    #
    # For more info on this substitution algorithm, see AnnotationAttribute#before_validation.
    @@default_attribute_identifier_template = "http://www.example.org/attribute#%s"

    # Defines a Proc that will be used to transform the value of AnnotationAttribute#name when generating the
    # AnnotationAttribute#identifier value. See AnnotationAttribute#before_validation for more info.
    @@attribute_name_transform_for_identifier = Proc.new { |name| name.to_s }
    
    def self.reset
      @@attribute_names_for_values_to_be_downcased = [ ]
      @@attribute_names_for_values_to_be_upcased = [ ]
      @@strip_text_rules = { }
      @@user_model_name = "User"
      @@limits_per_source = { }
      @@attribute_names_to_allow_duplicates = [ ]
      @@value_restrictions = { }
      @@default_attribute_identifier_template = "http://www.example.org/attribute#%s"
      @@attribute_name_transform_for_identifier = Proc.new { |name| name.to_s }
    end
    
    reset
    
    # This makes the variables above available externally.
    # Shamelessly borrowed from the GeoKit plugin.
    [ :attribute_names_for_values_to_be_downcased,
      :attribute_names_for_values_to_be_upcased,
      :strip_text_rules,
      :user_model_name,
      :limits_per_source,
      :attribute_names_to_allow_duplicates,
      :value_restrictions,
      :default_attribute_identifier_template,
      :attribute_name_transform_for_identifier ].each do |sym|
      class_eval <<-EOS, __FILE__, __LINE__
        def self.#{sym}
          if defined?(#{sym.to_s.upcase})
            #{sym.to_s.upcase}
          else
            @@#{sym}
          end
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end
      EOS
    end
  end
end