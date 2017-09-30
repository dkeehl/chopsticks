class Object
  def self.const_missing c
    require Chopsticks.to_underscore(c.to_s)
    const_defined?(c) ?  const_get(c) : super
  end

end
