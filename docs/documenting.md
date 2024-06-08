# Documenting

In Alfons 5.2, a new feature was implemented to document your own Taskfiles. Previously, there was no way to generate a help message, or to have shell completion. Thanks to the docstrings, and a little bit of magic, this is now possible.

## Docstrings

Docstrings are comments in the Taskfile that begin with `---`. These are followed by a tag (`@task`, `@argument`, `@flag`) that determines how the rest of the comment will be parsed.

The docstrings are untied from the actual code since it needs to be language-agnostic, and there are many ways within a single language to define tasks. As such, the tasks displayed in the new help message are a mix between documented tasks, and undocumented tasks read from the Taskfile.

## Declaring a task

`--- @task name Description of the task.`

A task is declared using the docstring above.

## Declaring an option for a task

`--- @option task [long s] <value> Description of the option.`

The docstring above has several parts. First, the name of the task that you are referencing. Then, between square brackets, you have to put all the forms of the option, the long preferrably first. Between the angle brackets, you can put each of the expected values. Everything that comes afterward is the description of the option.

## Flagging

`--- @flag * hide`
`--- @flag task hide`

As of right now, the only flag available is `hide`, which makes either all tasks (`*`) or a task invisible to autocompletion and the help message.
