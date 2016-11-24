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

  # Todo.sync functionality
  it 'should allow us to sync with the online todos service' do
    todos = [
      Todo.new('Remember the milk'),
      Todo.new('Buy a newspaper'),
      Todo.new('Do the washing up'),
      Todo.new('Buy some soya milk'),
      Todo.new('Go to sleep'),
      Todo.new('Remember the milk')
    ]
    Todo.sync
    Todo.class_variable_set(:@@todos, [])
    Todo.sync

    sent_data = []
    todos.each do |todo|
      sent_data.push [
        todo.instance_variable_get('@id'),
        todo.title,
        todo.due_date.to_s
      ]
    end
    received_data = []
    Todo.all.each do |todo|
      received_data.push [
        todo.instance_variable_get('@id'),
        todo.title,
        todo.due_date.to_s
      ]
    end
    expect(sent_data - received_data).to eq []
    # Teardown
    todos.each do |todo|
      HTTParty.delete(
        'http://lacedeamon.spartaglobal.com/todos/'\
        "#{todo.instance_variable_get('@id')}"
      )
    end
  end

  it 'should update the todo in the server if the local version is newer' do
    todo = Todo.new('Remember the milk')
    Todo.sync
    sleep(30) # To ensure the new title is more recent, as system times (between computer and API) may differ slightly. Could possibly use timecop to save time.
    todo.title = 'Get some bread instead'
    Todo.sync
    expect(todo.title).to eq 'Get some bread instead'
    expect(HTTParty.get(
      'http://lacedeamon.spartaglobal.com/todos/'\
      "#{todo.instance_variable_get('@id')}"
    )['title']).to eq 'Get some bread instead'
    # Teardown
    HTTParty.delete(
      'http://lacedeamon.spartaglobal.com/todos/'\
      "#{todo.instance_variable_get('@id')}"
    )
  end

  it 'should update a local todo if the version in the server is newer' do
    todo = Todo.new('Remember the milk')
    Todo.sync
    sleep(30) # To ensure the new title is more recent, as system times (between computer and API) may differ slightly. Could possibly use timecop to save time.
    HTTParty.patch(
      'http://lacedeamon.spartaglobal.com/todos/'\
      "#{todo.instance_variable_get('@id')}?"\
      'title=Get%20some%20bread%20instead'
    )
    Todo.sync
    expect(HTTParty.get(
      'http://lacedeamon.spartaglobal.com/todos/'\
      "#{todo.instance_variable_get('@id')}"
    )['title']).to eq 'Get some bread instead'
    expect(todo.title).to eq 'Get some bread instead'
    # Teardown
    HTTParty.delete(
      'http://lacedeamon.spartaglobal.com/todos/'\
      "#{todo.instance_variable_get('@id')}"
    )
  end
end
