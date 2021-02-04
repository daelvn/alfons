return {
  tasks = {
    install = function(self)
      if not (store.install == false) then
        return print("gonna install!")
      end
    end
  }
}
