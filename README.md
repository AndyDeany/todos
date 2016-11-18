# Todos project
Object oriented Ruby project. Created using test driven development (TDD).

## Specification
```Ruby
Todo.new("Remember the Milk", Date.today)
Todo.all #=> [<#Todo>, <#Todo>]
Todo.last #=> The latest Todo
Todo.find contains: "Milk"
Todo.find exactly: "Remember the Milk"

a = Todo.new("Buy a Newspaper") # Default dte should be today
a.title
a.due_date
a.title = "Some new Titls"
a.due_date = Date.parse("xxx") # Should only accept date objects

Todo.sync # Should Synchronise with online Todos Service. This is HARD!
```
