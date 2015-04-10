class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method("#{name}=") { |arg| self.instance_variable_set("@#{name}", arg) }
      define_method(name) { self.instance_variable_get("@#{name}") }
    end
  end
end
