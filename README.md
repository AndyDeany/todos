# Todos project
Object oriented Ruby project. Created using test driven development (TDD).

## Specification
```Ruby
Todo.new("Remember the milk", Date.today)
Todo.all #=> [<#Todo>, <#Todo>]
Todo.last #=> The latest Todo
Todo.find contains: "milk"
Todo.find exactly: "Remember the milk"

todo = Todo.new("Buy a newspaper") # Default date should be today
todo.title
todo.due_date
todo.title = "Some new title"
todo.due_date = Date.parse("2016-02-19") # Should only accept date objects

Todo.sync # Should Synchronise with online Todos Service. This is HARD!
```
