module Chopsticks
  def self.to_underscore(string)
    string.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr('-', '_').
      downcase
  end

  def self.to_camle_case(string)
    string.gsub(/(^|_|-)(.)/) { |_| $2.upcase  }
  end
end
