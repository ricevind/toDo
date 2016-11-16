

class Task
	constructor: (title, database, todo,  id = false, done = false, doneAt = null ) ->
		if not id then @id = Math.floor(Math.random()*(9999-1000+1)) + 1 else @id = id
		@title = title
		@done = done;
		@doneAt = doneAt

	markAsDone: (database, todo) ->
		@done = true
		@doneAt = new Date()

		$label = @$node.find('label')
		$label.addClass 'taskDone'

		$doneAtEm = $('<em>').text("(#{@doneAt.toLocaleString()})")
		$label.append $doneAtEm

		database.update(todo)

	markAsUndone: (database, todo) ->
		@done = false;
		@doneAt = null

		$label = @$node.find('label')
		$label.removeClass 'taskDone'

		$doneAtEm = @$node.find('em').remove()

		database.update(todo)

	getNodeString: (database, todo) ->
		task = @
		if not @$node?
			@$node = $("<li><input class='teal accent-2' type='checkbox' id='task-#{@id}'><label for='task-#{@id}'>#{@title}</label><i data-id='#{@id}'' class='js-remove-task material-icons right-float teal-text '>not_interested</i></li>")
			@$node.find('input').change ->
				if $(@).is(":checked") then task.markAsDone(database, todo) else task.markAsUndone(database, todo)
		@$node

	toString: ->
		data = {
			id: @id
			title: @title
			done: @done;
			doneAt: @doneAt
		}
		JSON.stringify data


class TaskCollection
	constructor: ($list, tasks = {}) ->
		@tasks = tasks
		@list = $list
		@list.html ''

		@.addTasks tasks

	addTask: (task, database) ->
		taskNode = task.getNodeString(database, @)
		taskNode.hide()
		@list.prepend taskNode
		taskNode.fadeIn(800)
		if task.doneAt
			taskNode.find('input').prop('checked', true).change()
		# @list.fadeOut().fadeIn();
		# task.getNodeString(database, @).fadeIn()
		@tasks[task.id] = task

	addTasks: (tasks) ->
		@.addTask task for task in @tasks

	getTask: (taskID) ->
		@tasks[taskID]

	clearTask: (taskID, database) ->
		$("#task-#{taskID}").parent('li').animate({height:0, padding:0, border:0}).fadeOut

		database.removeItem(taskID);

		delete @tasks.taskID

	clearTasks: ->
		@list.html ''


class Storage
	constructor: (name) ->
		@name = name
		if localStorage.hasOwnProperty name
			@storage = []
			@getItems()
		else
			@storage = []
			localStorage.setItem name, JSON.stringify @storage

	setItem: (item) ->
		@storage.push(item)
		console.log JSON.stringify @storage
		localStorage.setItem @name, JSON.stringify @storage
	getItems: () ->
		@storage = JSON.parse localStorage.getItem @name
		@storage
	getItem: (id) ->
		for dataInString in @storage
			data = JSON.parse(dataInString)
			if data.id is id then return data else return false
	removeItem: (id) ->
		console.log 'start ofremoving', id
		for dataInString in @storage
			data = JSON.parse(dataInString)
			if data.id == parseInt id
				index = @storage.indexOf(dataInString)
				@storage.splice index, 1
				localStorage.setItem @name, JSON.stringify @storage
	update: (todo)->
		for id of todo.tasks
			task = todo.tasks[id]
			taskInString = task.toString()
			for storagedTaskInString in @storage
				storagedTask = JSON.parse(storagedTaskInString)
				if storagedTask.id == parseInt id
					index = @storage.indexOf(storagedTaskInString)
					@storage[index] = taskInString

		localStorage.setItem @name, JSON.stringify @storage

$ ->



	database = new Storage 'tasks'
	initialize = ->
		dummyTasks = [
			"Testowe zadanie"
			"Pamiętaj by nas usunac"
		]
		if database.getItems().length is 0
			for task in dummyTasks
				newTask = new Task task, database, todo
				database.setItem newTask.toString()
	# initialize()

	todo = new TaskCollection $('.js-todo-list')

	loadTasks = ->
		# console.log storagedTasks.split ',', storagedTasks.length
		for taskInString in database.getItems()
			# console.log(taskInString)
			taskData = JSON.parse taskInString
			console.log taskData.id
			task = new Task taskData.title, database, todo, taskData.id, taskData.done, taskData.doneAt
			# console.log task
			todo.addTask task, database

	loadTasks()

	$('.js-noweZadanie').keypress (evt) ->
		# evt.preventDefault();
		taskTitle = @.value
		# console.log taskTitle
		if evt.which is 13
			task = new Task taskTitle, database, todo
			todo.addTask task, database
			database.setItem task.toString()

			@.value = ''
			# console.log @
			# $(@).blur()


	$('#js-add').click (evt) ->
		evt.preventDefault()
		$('.js-noweZadanie')[0].focus()

	$(document).on 'click', '.js-remove-task', (evt) ->
		evt.preventDefault()
		console.log 'clicked remove'
		id = $(@).data('id')
		todo.clearTask(id, database)

	$('.btn-large').click (evt) ->

		for task of todo.tasks
			console.log task
			if  todo.tasks[task].done then todo.clearTask(task, database)

	$('#js-remove-list').click (evt) ->
		evt.preventDefault()

		if confirm "Napewno usunac wszystkie zadania ?"
			localStorage.clear()
			database.storage = [];
		todo.clearTasks()
		# initialize()
		# loadTasks()
		undefined