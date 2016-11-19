describe Todo do
  before(:each) { Todo.class_variable_set(:@@todos, []) }
  # Initialisation
  it 'should initialise with both arguments' do
    todo = Todo.new('Remember the milk', Date.parse('21 Feb 2015'))
    expect(todo.title).to eq 'Remember the milk'
    expect(todo.due_date).to eq Date.parse('21 Feb 2015')
  end

  it 'should initialise with no due_date given' do
    todo = Todo.new('Remember the milk')
    expect(todo.title).to eq 'Remember the milk'
    expect(todo.due_date).to eq Date.today
  end

  it 'should throw an error if .new is given a non-string title' do
    expect { Todo.new(:not_a_string, Date.today) }.to raise_error(
      ArgumentError, 'arguments must be a string and a Date object'
    )
  end

  it 'should throw an error if .new is given a non-Date object due_date' do
    expect { Todo.new('Remember the milk', 'Not Date object') }.to raise_error(
      ArgumentError, 'arguments must be a string and a Date object'
    )
  end

  # Setters and getters
  it 'should allow us to set the title of an existing todo' do
    todo = Todo.new('Remember the milk', Date.today)
    todo.title = 'Forget the milk, get some bread'
    expect(todo.title).to eq 'Forget the milk, get some bread'
  end

  it 'should allow us to set the due_date of an existing todo' do
    todo = Todo.new('Remember the milk', Date.today)
    todo.due_date = Date.parse('21 Feb 2015')
    expect(todo.due_date).to eq Date.parse('21 Feb 2015')
  end

  #it 'should only allow us to assign Date objects to due_date' do
  #end

  # Behaviour
  it 'should allow us to get an array of all instantiated todos' do
    todo1 = Todo.new('Remember the milk')
    todo2 = Todo.new('Buy a newspaper')
    todo3 = Todo.new('Do the washing up')
    todo4 = Todo.new('Buy some soya milk')
    todo5 = Todo.new('Go to sleep')
    expect(Todo.all).to eq [todo1, todo2, todo3, todo4, todo5]
  end

  it 'should allow us to get the latest todo' do
    Todo.new('Remember the milk')
    Todo.new('Buy a newspaper')
    Todo.new('Do the washing up')
    Todo.new('Buy some soya milk')
    todo5 = Todo.new('Go to sleep')
    expect(Todo.last).to eq todo5
  end

  it 'should allow us to get todos whose titles contain a given string' do
    todo1 = Todo.new('Remember the milk')
    Todo.new('Buy a newspaper')
    Todo.new('Do the washing up')
    todo4 = Todo.new('Buy some soya milk')
    Todo.new('Go to sleep')
    expect(Todo.find(contains: 'milk')).to eq [todo1, todo4]
  end

  it 'should allow us to get todos whose titles match a given string exactly' do
    todo1 = Todo.new('Remember the milk')
    Todo.new('Buy a newspaper')
    Todo.new('Do the washing up')
    Todo.new('Buy some soya milk')
    Todo.new('Go to sleep')
    todo6 = Todo.new('Remember the milk')
    expect(Todo.find(exactly: 'Remember the milk')).to eq [todo1, todo6]
  end

  it 'should allow us to sync with the online todos service' do
    todo1 = Todo.new('Remember the milk')
    todo2 = Todo.new('Buy a newspaper')
    todo3 = Todo.new('Do the washing up')
    todo4 = Todo.new('Buy some soya milk')
    todo5 = Todo.new('Go to sleep')
    todo6 = Todo.new('Remember the milk')
    Todo.sync
    Todo.class_variable_set(:@@todos, [])
    Todo.sync

    sent_data = []
    [todo1, todo2, todo3, todo4, todo5, todo6].each do |todo|
      sent_data.push [
        todo.instance_variable_get('@id'),
        todo.title,
        todo.due_date
      ]
    end
    received_data = []
    puts Todo.all.length
    Todo.all.each do |todo|
      received_data.push [
        todo.instance_variable_get('@id'),
        todo.title,
        todo.due_date
      ]
    end

    expect(sent_data - received_data).to eq []
  end

  it 'should assign each todo a "created_at" date/time when synced' do
    Todo.new('Remember the milk', '2016-12-21')
    Todo.sync
    expect(HTTParty.get(
      "http://lacedeamon.spartaglobal.com/todos/#{todo.id}"
    )['created_at'][0..-6]).to eq DateTime.now.strftime('%Y-%M-%dT%H:%M:%S')
    # (should be correct to the nearest second, but get requests take time...)
    # [insert get request for date here. Parse the date and time to check it's
    #  correct, or at least pretty close]
  end

  it 'should assign each todo an "updated_at" date/time when synced' do
    todo = Todo.new('Remember the milk', '2016-12-21')
    Todo.sync
    get_request1 = HTTParty.get(
      "http://lacedeamon.spartaglobal.com/todos/#{todo.id}"
    )
    expect(get_request1['updated_at']).to eq get_request1['created_at']
    todo.title = 'Get some bread instead'
    Todo.sync
    get_request2 = HTTParty.get(
      "http://lacedeamon.spartaglobal.com/todos/#{todo.id}"
    )
    expect(get_request2['updated_at'][0..-6]).to eq(
      DateTime.now.strftime('%Y-%M-%dT%H:%M:%S')
    )
    expect(get_request2['updated_at']).not_to eq get_request2['created_at']
    expect(get_request2['created_at']).not_to eq get_request1['created_at']
  end

  it 'should update the same todo in the server if a todo is updated' do
    todo = Todo.new('Remember the milk', '2016-12-21')
    Todo.sync
    todo.title = 'Get some bread instead'
    Todo.sync
    expect(HTTParty.get(
      "http://lacedeamon.spartaglobal.com/todos/#{todo.id}"
    )['title']).to eq 'Get some bread instead'
  end
end
