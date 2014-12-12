module LastN
  def last(n)
    self[-n,n]
  end
end

class String
  include LastN
end

