describe Todo do
  # Tests for created_at time and update_time.
  # These are unnecessary as API does this for us.
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
end
