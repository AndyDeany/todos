require 'date'

class Todo # :nodoc:
  attr_accessor :title, :due_date

  @@todos = []

  ## Getters
  def self.all
    @@todos.dup
  end

  def self.last
    @@todos.last
  end

  ## Behaviour
  def self.find(params)
    results = []
    unless params[:contains].nil?
      @@todos.each do |todo|
        results.push todo if todo.title.include? params[:contains]
      end
    end
    unless params[:exactly].nil?
      @@todos.each do |todo|
        results.push todo if todo.title == params[:exactly]
      end
    end
    results
  end

  def initialize(title, due_date=Date.today)
    unless title.is_a? String and due_date.is_a? Date
      raise ArgumentError, 'arguments must be a string and a Date object'
    end
    @title = title
    @due_date = due_date
    @@todos.push self
  end
end
