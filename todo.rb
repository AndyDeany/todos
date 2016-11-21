require 'date'
require 'httparty'

class Todo # :nodoc:
  attr_accessor :title, :due_date

  ### Class methods and variables

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

  def self.sync
    attr_accessor :id
    puts "Syncing todos..."
    current_ids = get_current_ids
    local_ids = Todo.all.collect { |todo| todo.id }
    current_ids.each { |id| get_todo(id, local_ids, current_ids) }
    Todo.all.each do |todo|
      if todo.id.nil?
        todo.id = HTTParty.post(
          "http://lacedeamon.spartaglobal.com/todos?"\
          "title=#{todo.title}&"\
          "due=#{todo.due_date}"
        )['id']
      elsif not current_ids.include? todo.id # Only todos that we didn't just 'get' should be 'put'
        HTTParty.put(
          "http://lacedeamon.spartaglobal.com/todos/#{todo.id}?"\
          "title=#{todo.title}&"\
          "due=#{todo.due_date}"
        )
      end
    end
    undef :id, :id=
  end

  def self.get_current_ids
    HTTParty.get(
      'http://lacedeamon.spartaglobal.com/todos'
    ).collect { |todo| todo['id'] }
  end

  def self.get_todo(id, local_ids, current_ids)
    puts "Getting todo #{current_ids.index(id)+1} of #{current_ids.length}..."
    received_todo = HTTParty.get("http://lacedeamon.spartaglobal.com/todos/#{id}")

    Todo.all.each do |todo|
      if id == todo.id
        todo.title = received_todo['title']
        todo.due_date = Date.parse(received_todo['due'])
        return
      end
    end
    Todo.new(received_todo['title'], Date.parse(received_todo['due']))
  end

  def self.generate_id(current_ids)
    8380.upto(9000) { |id| return id unless current_ids.include? id }
    raise Error, 'No ids available. You must delete some todos.'
  end

  private_class_method :get_current_ids, :get_todo, :generate_id

  ### Instance methods and variables
  def initialize(title, due_date=Date.today)
    unless title.is_a? String and due_date.is_a? Date
      raise ArgumentError, 'arguments must be a string and a Date object'
    end
    @id = nil
    @title = title
    @due_date = due_date
    @@todos.push self
  end
end
