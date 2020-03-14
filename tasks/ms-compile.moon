=>
  for file in wildcard "**.moon"
    continue if file\match "Alfons%.moon"
    moonc file