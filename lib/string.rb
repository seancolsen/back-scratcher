class String

  def flatten
    self.gsub(/\s+/,' ').strip 
  end

  def unindent
    space = self.scan(/^\s*/)[0]
    self.gsub(/^#{space}/,'')
  end

end
