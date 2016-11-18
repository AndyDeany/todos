describe Todo do
  # Initialisation
  it 'should initialise with both arguments' do
    todo = Todo.new('Remember the milk', Date.today)
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
end
