
require 'active_model'

class CuhkLibRequestItem < RequestItem
  attr_accessor :user_type, :library_id

  def initialize(hash)
    self.members.each do |sym|
      self[sym] = hash.fetch(sym,nil)
    end
    self.user_type =  hash.fetch("user_type",nil)
    self.library_id = hash.fetch("library_id",nil)
  end

  def validate
    errs = super
    errs.push(I18n.t('request.errors.user_type')) if self.user_type.blank?
    errs
  end

  def to_text_array(skip_empty = false)
    arr = super

    arr.push("user_type: #{self.user_type}") unless skip_empty && self.user_type.blank?
    arr.push("library_id: #{self.library_id}") unless skip_empty && self.library_id.blank?
    
    %i(user_type library_id).each do |sym|
      
    end
    

    arr
  end
end