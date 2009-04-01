class Symbol
  def to_proc
    lambda {|i| i.send(self)}
  end
end