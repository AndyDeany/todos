require 'date'
require 'httparty'

class Todo # :nodoc:
  attr_accessor :title, :due_date
  attr_reader :id

  ### Class methods and variables

  @@todos = []

  @@current_ids = []
  @@server_todos = []

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
    @@server_todos = []
    @@current_ids.each { |id| get_todo id }

    puts "...\nUploading todos..."
    Todo.all.each { |todo| upload todo }

    puts "...\nSync complete.\n-----\n"
    undef :id=, :updated_at, :updated_at=
  end

  def self.get_current_ids
    HTTParty.get(url).collect { |todo| todo['id'] }
  end

  def self.get_todo(id)
    puts "Getting todo #{@@current_ids.index(id) + 1} of "\
    "#{@@current_ids.length}..."

    server_todo = HTTParty.get(url("/#{id}"))
    @@server_todos.push server_todo # Storing server todos so upload() can use them without needing to send more GET requests

    Todo.all.each do |todo|
      next unless id == todo.id and not local_newer?(todo, server_todo)
      update_todo(todo, server_todo)
      return
    end
    create_todo(server_todo)
  end

  def self.upload(todo)
    title = todo.title.gsub(' ', '%20')
    due = todo.due_date.to_s
    if todo.id.nil?
      post = post_todo(title, due)
      todo.id = post['id']
      todo.updated_at = DateTime.parse(post['updated_at'])
    elsif local_newer?(todo) or not @@current_ids.include? todo.id # Only todos that we didn't just 'get' should be 'put'
      put_todo(todo.id, title, due)
    end
  end

  def self.update_todo(local, server)
    local.title = server['title']
    local.due_date = Date.parse(server['due'])
  end

  def self.create_todo(server)
    new_todo = Todo.new(server['title'], Date.parse(server['due']))
    new_todo.id = server['id']
    new_todo.updated_at = DateTime.parse(server['updated_at'])
  end

  def self.post_todo(title, due)
    HTTParty.post(url("?title=#{title}&due=#{due}"))
  end

  def self.put_todo(id, title, due)
    HTTParty.put(url("/#{id}?title=#{title}&due=#{due}"))
  end

  def self.local_newer?(local, server=find_server_todo(local.id))
    local.updated_at > DateTime.parse(server['updated_at'])
  end

  def self.find_server_todo(id)
    @@server_todos.select { |todo| todo['id'] == id }[0]
  end

  private_class_method :get_current_ids, :get_todo, :upload, :update_todo, :create_todo, :post_todo, :put_todo, :local_newer?, :find_server_todo

  ### Instance methods and variables
  def initialize(title, due_date=Date.today)
    unless title.is_a? String and due_date.is_a? Date
      raise ArgumentError, 'arguments must be a string and a Date object'
    end
    @title = title
    @due_date = due_date
    # Attributes for the lacedeamon API
    @id = nil
    @updated_at = nil

    @@todos.push self
  end

  ## Setters
  def title=(new_title)
    raise ArgumentError, 'title must be a string' unless new_title.is_a? String
    @title = new_title
    @updated_at = DateTime.now
  end

  def due_date=(new_date)
    raise ArgumentError, 'due_date must be a Date object' unless new_date.is_a? Date
    @due_date = new_date
    @updated_at = DateTime.now
  end
end

#URL helper
def url(path = '/')
  "http://lacedeamon.spartaglobal.com/todos#{path}"
end
