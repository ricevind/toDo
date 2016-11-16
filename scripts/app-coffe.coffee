initialize = ->

	dummyTasks = [
		"Testowe zadanie"
		"Pamiętaj by nas usunac"
	]

	if not localStorage.getItem 'tasks'
		localStorage.setItem 'tasks', dummyTasks
initialize()
# localStorage.setItem 'tasks', dummyTasks

class Task
	constructor: (title, done = false) ->
		@id = Math.floor(Math.random()*(9999-1000+1)) + 1
		@title = title
		@done = done;
		@doneAt = null;

	markAsDone: ->
		@done = true
		@doneAt = new Date()

		$label = @$node.find('label')
		$label.addClass 'taskDone'

		$doneAtEm = $('<em>').text("(#{@doneAt.toLocaleString()})")
		$label.append $doneAtEm

	markAsUndone: ->
		@done = false;
		@doneAt = null

		$label = @$node.find('label')
		$label.removeClass 'taskDone'

		$doneAtEm = @$node.find('em').remove()

	getNodeString: ->
		task = @
		if not @$node?
			@$node = $("<li><input class='teal accent-2' type='checkbox' id='task-#{@id}'><label for='task-#{@id}'>#{@title}</label><i data-id='#{@id}'' class='js-remove-task material-icons right-float teal-text '>not_interested</i></li>")
			@$node.find('input').change ->
				if $(@).is(":checked") then task.markAsDone() else task.markAsUndone()
		@$node

class TaskCollection
	constructor: ($list, tasks = {}) ->
		@tasks = tasks
		@list = $list
		@list.html ''

		@.addTasks tasks

	addTask: (task) ->
		@list.append task.getNodeString().hide()
		# @list.fadeOut().fadeIn();
		task.getNodeString().fadeIn()
		@tasks[task.id] = task

	addTasks: (tasks) ->
		@.addTask task for task in @tasks

	getTask: (taskID) ->
		@tasks[taskID]

	clearTask: (taskID) ->
		$("#task-#{taskID}").parent('li').animate({height:0, padding:0, border:0}).fadeOut
		title = $("#task-#{taskID}").siblings('label').html()
		storaged = localStorage.getItem('tasks')
		updated = storaged.replace(title, '').replace(',,', ',')
		if updated[-1] is ',' then updated = updated.slice(0,-1)
		if updated[0] is ',' then updated = updated.slice(1)
		localStorage.setItem('tasks', updated)
		delete @tasks.taskID

	clearTasks: ->
		@list.html ''

$ ->

	todo = new TaskCollection $('.js-todo-list')

	loadTasks = ->
		storagedTasks = localStorage.getItem "tasks"
		# console.log storagedTasks.split ',', storagedTasks.length
		if storagedTasks then for taskTitle in storagedTasks.split ','
			task = new Task taskTitle
			console.log task
			todo.addTask task

	loadTasks()

	$('.js-noweZadanie').keypress (evt) ->
		# evt.preventDefault();
		taskTitle = @.value
		# console.log taskTitle
		if evt.which is 13
			task = new Task taskTitle
			todo.addTask task
			storaged = localStorage.getItem('tasks')
			updated = storaged + ',' + taskTitle
			localStorage.setItem('tasks', updated)

			@.value = ''
			# console.log @
			$(@).blur()


	$('#js-add').click (evt) ->
		evt.preventDefault()
		$('.js-noweZadanie')[0].focus()

	$(document).on 'click', '.js-remove-task', (evt) ->
		evt.preventDefault()
		id = $(@).data('id')
		console.log @
		todo.clearTask(id)
	$('.btn-large').click (evt) ->
		console.log todo.tasks
		for task of todo.tasks
			console.log task
			if  todo.tasks[task].done then todo.clearTask(task)
	$('#js-remove-list').click (evt) ->
		evt.preventDefault()
		localStorage.clear() if confirm "Napewno usunac wszystkie zadania ?"

		todo.clearTasks()
		# initialize()
		loadTasks()
		undefined