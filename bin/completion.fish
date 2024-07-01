# clear completions
complete -e alfons

# remove file completion
complete -c alfons -f

# simple completions for --help --list --zsh-list --bash-list
complete -c alfons -l help -d 'Show help'
complete -c alfons -l list -d 'List tasks'
complete -c alfons -l zsh-list -d 'List tasks (zsh/fish completion)'
complete -c alfons -l bash-list -d 'List tasks (bash completion)'

# complete -f and --file with paths
complete -c alfons -s f -l file -r -F -d 'Use a specific task file'

# function to find the used taskfile
function __alfons_find_taskfile
	set -l taskfile ''
	set -l next 0
	for arg in (commandline -o)
		if [ $next = 1 ]
			set taskfile "$arg"
			break
		end
		if [ "$arg" = "-f" ]; or [ "$arg" = "--file" ]
			set next 1
		end
	end
	echo "$taskfile"
end

# function to get the command invocation for alfons with the taskfile
function __alfons_invoke
	set -l taskfile (__alfons_find_taskfile)
	echo alfons
	if [ -n "$taskfile" ]
		echo -f
		echo "$taskfile"
	end
end

# function to complete the available tasks in the taskfile
function __alfons_complete_tasks
	set -l alfons (__alfons_invoke)
	$alfons --zsh-list 2>/dev/null | sed s/:/\t/
end

# function to list the available tasks in the taskfile
function __alfons_list_tasks
	set -l alfons (__alfons_invoke)
	$alfons --list 2>/dev/null | sed 's/ /\n/g'
end

# function to list the available options for all tasks
function __alfons_list_all_options
	set -l alfons (__alfons_invoke)
	for task in ($alfons --list 2>/dev/null | sed 's/ /\n/g')
		for option in ($alfons --list-options "$task" 2>/dev/null | sed 's/ /\n/g')
			echo "$task::$option"
		end
	end
end

# function to find the currently selected task
function __alfons_selected_task
	set -l skip 0
	set -l task ''
	set -l first 1
	for arg in (commandline -o)
		if [ $first = 1 ]; or [ $skip = 1 ]
			set skip 0
			set first 0
			continue
		end
		if [ "$arg" = --list ]
			continue
		end
		if [ "$arg" = -f ]; or [ "$arg" = --file ]; or [ "$arg" = --help ]
			set skip 1
			set task ''
		else if [ (string sub -s1 -e1 -- "$arg") = '-' ]
			set skip 1
		else
			set task "$arg"
		end
	end
	echo "$task"
end

# function to complete options for the selected task
function __alfons_complete_options
	set -l alfons (__alfons_invoke)
	set -l task (__alfons_selected_task)
	for option in ($alfons --zsh-list-options $task 2>/dev/null)
		set -l parts (string split -m1 -- '\:' "$option")
		printf '%s' $parts[1]
		if [ -n "$parts[2]" ]
			printf '\t'
			string sub -s2 -e-2 -- "$parts[2]"
		else
			echo
		end
	end
		
end

# function to check if we are in an option
function __alfons_get_option
	set -l args (commandline -o)
	if [ (string sub -s1 -e1 -- "$args[-1]") = '-' ]
		printf '%s' "$args[-1]"
	end
end

# function to actually complete files if option asks for it
function __alfons_needs_option
	set -l task (__alfons_selected_task)
	if [ -z "$task" ]
		return 1
	end
	set -l option (__alfons_get_option)
	if [ -z "$option" ]
		return 1
	end
	set -l alfons (__alfons_invoke)
	set -l type ($alfons --zsh-get-option-type "$task::$option" 2>/dev/null)
	for arg in $argv
		if [ "$type" = "$arg" ]
			return 0
		end
	end
	return 1
end

# complete the available tasks for the selected taskfile
complete -c alfons -n '[ -z (__alfons_get_option) ]' -a '(__alfons_complete_tasks)' -d 'Run the task'

# complete the help function with the available tasks
complete -c alfons -l help -f -r -a '(__alfons_complete_tasks)' -d 'Show help for a task'

# complete the list-options / zsh-list-options / bash-list-options function with the available tasks
complete -c alfons -l list-options -f -r -a '(__alfons_list_tasks)' -d 'List options for a task'
complete -c alfons -l zsh-list-options -f -r -a '(__alfons_list_tasks)' -d 'List options for a task (zsh/fish completion)'
complete -c alfons -l bash-list-options -f -r -a '(__alfons_list_tasks)' -d 'List options for a task (bash completion)'

# complete the get-option-type / zsh-get-option-type function
complete -c alfons -l get-option-type -f -r -a '(__alfons_list_all_options)' -d 'Get the type of an option'
complete -c alfons -l zsh-get-option-type -f -r -a '(__alfons_list_all_options)' -d 'Get the type of an option (zsh/fish completion)'

# complete the task options for the selected task
complete -c alfons -n '[ -n (__alfons_selected_task) ]; and [ -z (__alfons_get_option) ]' -a '(__alfons_complete_options)' -d 'Options for the task'

# complete files if task option asks for file
complete -c alfons -n '__alfons_needs_option _files _path_files' -F

# complete users/groups if task option asks for it
complete -c alfons -n '__alfons_needs_option _users' -a '(__fish_complete_users)'
complete -c alfons -n '__alfons_needs_option _groups' -a '(__fish_complete_groups)'