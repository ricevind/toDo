dummyTasks = [
	"Testowe zadanie"
	"Pamiętaj by nas usunac"

]

if not localStorage.getItem 'tasks'
	 localStorage.setItem 'tasks', dummyTasks

# localStorage.setItem 'tasks', dummyTasks

class Task
	constructor: (title, done = false) ->
		@id = Math.floor(Math.random()*(9999-1000+1)) + 1
		@title = title
		@done = done;
		@doneAt = null;

	getNodeString: ->
		if not @$node?
			@$node = $("<li><input class='teal accent-2' type='checkbox' id='task-#{@id}'><label for='task-#{@id}'>#{@title}</label><a href='#'><i class='material-icons right-float teal-text '>not_interested</i></a></li>")
		@$node

class TaskCollection
	constructor: ($list, tasks = {}) ->
		@tasks = tasks
		@list = $list
		@list.html ''

		@.addTasks tasks

	addTask: (task) ->
		@list.append task.getNodeString()
		@tasks[task.id] = task

	addTasks: (tasks) ->
		@.addTask task for task in @tasks

	getTask: (taskID) ->
		@tasks[taskID]

$ ->

	todo = new TaskCollection $('.js-todo-list')

	loadTasks = ->
		storagedTasks = localStorage.getItem "tasks"
		# console.log storagedTasks.split ',', storagedTasks.length
		for taskTitle in storagedTasks.split ','
			task = new Task taskTitle
			todo.addTask task

	loadTasks()

	$('#js-remove-list').click (evt) ->
		evt.preventDefault()
		localStorage.clear() if confirm "Napewno usunac wszystkie zadania ?"
		undefined