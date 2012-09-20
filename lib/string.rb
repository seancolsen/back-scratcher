class String

def flatten
  self.gsub(/\s+/,' ').strip 
end

end
