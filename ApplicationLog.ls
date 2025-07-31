
  do ->

    { create-instance } = dependency 'reflection.Instance'

    { value-as-string } = dependency 'reflection.Value'
    { get-timestamp } = dependency 'unsafe.Date'

    screen-buffer-write = (screen-buffers, id, message) ->

      { cursor } = screen-buffers[ id ] ; cursor! => ..goto ..row + 1, 0 ; ..write message

    create-application-log = (screen-buffers) ->

      screen-buffer-id = screen-buffers.create-screen-buffer!

      line-count = 0

      log = -> screen-buffer-write screen-buffers, screen-buffer-id, it ; line-count++

      get-screen-buffer = -> screen-buffers.get-screen-buffer screen-buffer-id

      goto = (row) -> get-screen-buffer!cursor!goto row, 0

      instance = create-instance do

        activate: member: -> get-screen-buffer!activate!

        log: member: (message) -> log [ get-timestamp!, message ] * ' '

        goto-line: member: (line) -> goto line

        goto-last-line: member: -> goto line-count

        get-commands: member: ->

          ApplicationLogActivate: -> instance.activate!
          ApplicationLogWrite: -> instance.log [ "#arg" for arg in arguments ] * ' '
          ApplicationLogGotoLine: (line) -> instance.goto-ine parse-int line, 10
          ApplicationLogGotoLastLine: -> instance.goto-last-line!

      instance

    {
      create-application-log
    }