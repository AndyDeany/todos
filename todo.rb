require 'date'

class Todo # :nodoc:
  attr_accessor :title, :due_date

  def initialize(title, due_date)
    unless (title.is_a? String) && (due_date.is_a? Date)
      raise ArgumentError, 'arguments must be a string and a Date object'
    end
    @title = title
    @due_date = due_date
  end
end
