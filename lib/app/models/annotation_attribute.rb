class AnnotationAttribute < ActiveRecord::Base
  validates_presence_of :name,
                        :identifier
  
  validates_uniqueness_of :name,
                          :case_sensitive => false

  validates_uniqueness_of :identifier,
                          :case_sensitive => false
                          
  has_many :annotations,
           :foreign_key => "attribute_id"

  # If the identifier is not set, generate it before validation takes place.
  # See Annotations::Config::default_attribute_identifier_template
  # for more info
  def before_validation
    unless self.name.blank? or !self.identifier.blank?
      if self.name.match(/^http:\/\//) or self.name.match(/^urn:/) or self.name.match(/^<.+>$/)
        self.identifier = self.name
      else
        self.identifier = (Annotations::Config::default_attribute_identifier_template % self.name)
      end
    end
  end
end