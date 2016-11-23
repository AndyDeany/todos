require 'date'
require 'httparty'

class Todo # :nodoc:
  attr_accessor :title, :due_date

  ### Class methods and variables

  @@todos = []

  @@current_ids = []
  @@received_todos = []

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
    attr_accessor :id, :updated_at
    puts "\n-----\nSyncing todos..."
    puts "...\nDownloading todos..."
    @@current_ids = get_current_ids
    @@received_todos = []
    @@current_ids.each { |id| get_todo(id) }
    puts "...\nUploading todos..."
    Todo.all.each { |todo| upload_todo(todo) }
    puts "...\nSync complete.\n-----\n"
    undef :id, :id=, :updated_at, :updated_at=
  end

  def self.get_current_ids
    HTTParty.get(
      'http://lacedeamon.spartaglobal.com/todos'
    ).collect { |todo| todo['id'] }
  end

  def self.get_todo(id)
    puts "Getting todo #{@@current_ids.index(id) + 1} of "\
    "#{@@current_ids.length}..."

    received_todo = HTTParty.get(
      "http://lacedeamon.spartaglobal.com/todos/#{id}"
    )
    @@received_todos.push received_todo
    Todo.all.each do |todo|
      if ((id == todo.id) and (DateTime.parse(received_todo['updated_at']) > todo.updated_at))
        todo.title = received_todo['title']
        todo.due_date = Date.parse(received_todo['due'])
        return nil
      end
    end
    new_todo = Todo.new(received_todo['title'], Date.parse(received_todo['due']))
    new_todo.id = received_todo['id']
    new_todo.updated_at = DateTime.parse(received_todo['updated_at'])
  end

  def self.upload_todo(todo)
    title = todo.title.gsub(' ', '%20')
    due = todo.due_date.to_s
    if todo.id.nil?
      post = HTTParty.post(
        'http://lacedeamon.spartaglobal.com/todos?'\
        "title=#{title}&"\
        "due=#{due}"
      )
      todo.id, todo.updated_at = post['id'], DateTime.parse(post['updated_at'])
    elsif ((todo.updated_at > DateTime.parse(@@received_todos.select { |received_todo| received_todo['id'] == todo.id }[0]['updated_at'])) or
      (not @@current_ids.include? todo.id)) # Only todos that we didn't just 'get' should be 'put'
      HTTParty.put(
        "http://lacedeamon.spartaglobal.com/todos/#{todo.id}?"\
        "title=#{title}&"\
        "due=#{due}"
      )
    end
  end

  private_class_method :get_current_ids, :get_todo, :upload_todo

  ### Instance methods and variables
  def initialize(title, due_date=Date.today)
    unless title.is_a? String and due_date.is_a? Date
      raise ArgumentError, 'arguments must be a string and a Date object'
    end
    @id = nil
    @title = title
    @due_date = due_date
    @updated_at = nil
    @@todos.push self
  end

  ## Setters
  def title=(new_title)
    @title = new_title
    @updated_at = DateTime.now
  end

  def due_date=(new_date)
    @due_date = new_date
    @updated_at = DateTime.now
  end
end
