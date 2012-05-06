class String
  def to_utf8
    self.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16')
  end

  def to_utf8!
    self.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode!('UTF-8', 'UTF-16')
  end
end