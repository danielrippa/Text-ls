
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { create-screen-buffer } = dependency 'tui.console.ScreenBuffer'
    { get-timestamp } = dependency 'unsafe.Date'

    create-id = -> "screen-buffer-#{ get-timestamp! }"

    create-screen-buffer-manager = ->

      screen-buffers = {}

      create-instance do

        create-screen-buffer: member: -> id = create-id! ; screen-buffers[ id ] := create-screen-buffer! ; id

        get-screen-buffer-by-id: member: -> screen-buffers[ it ]

        get-commands: member: ->

          ScreenBufferCreate: ->

    {
      create-screen-buffer-manager
    }

