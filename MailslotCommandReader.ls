
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { create-mailslot-server } = dependency 'os.win32.MailslotServer'
    { script-name } = dependency 'os.shell.Script'
    { string-split-by-first-segment, string-split-at-index } = dependency 'unsafe.String'

    command-name-as-canonical-name-or-alias = (string) ->

      [ first, rest ] = string `string-split-at-index` 1

      switch first

        | '.' => string

        else "/#string"

    parse-command-message = (message) ->

      [ command-name, command-arguments ] = string-split-by-first-segment message, ' '

      command-name = command-name-as-canonical-name-or-alias command-name

      [ command-name, command-arguments / ' ' ]

    create-mailslot-command-reader = ->

      mailslot-server = create-mailslot-server script-name ; reading = off

      instance = create-instance do

        is-running: member: -> mailslot-server.is-listening!

        start: member: -> mailslot-server.start!
        stop:  member: -> mailslot-server.stop!

        has-pending-commands: member: -> mailslot-server.has-messages!

        read-command: member: ->

          message = mailslot-server.read-message! ; return if message is void
          parse-command-message message

        get-commands: member: ->

          MailslotCommandReaderStart: -> instance.start!
          MailslotCommandReaderStop:  -> instance.stop!

          MailslotCommandReaderHasPendingCommands: -> instance.has-pending-commands!

    {
      create-mailslot-command-reader
    }