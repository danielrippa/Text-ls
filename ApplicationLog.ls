
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { create-log-file } = dependency 'os.filesystem.LogFile'
    { debug } = dependency 'os.shell.IO'
    { get-timestamp } = dependency 'unsafe.Date'
    { value-as-string } = dependency 'reflection.Value'

    as-string = -> "#{ get-timestamp! } #{ [ (value-as-string arg) for arg in it ] * ' ' }"

    screen-buffer-write = (screen-buffer, entry) ->

      screen-buffer => ..cursor!new-line! ; ..write entry

    create-application-log = (screen-buffer) ->

      log-file = create-log-file!

      log = (args, type) ->

        entry = as-string args ; debug entry ; log-file.write entry ; screen-buffer-write screen-buffer, entry

      instance = create-instance do

        activate: member: -> screen-buffer.activate!

        start: member: -> log-file.start!
        stop: member: -> log-file.stop!

        write-error: member: -> log arguments, 'ERROR'
        write-info: member:  -> log arguments, 'INFO'

        get-commands: member: ->

          ApplicationLogActivate: -> instance.activate!
          ApplicationLogStart: -> instance.start!
          ApplicatinLogStop: -> instance.stop!

          ApplicationLogWriteError: -> instance.write-error ...
          ApplicationLogWriteInfo: -> instance.write-info ...

    {
      create-application-log
    }