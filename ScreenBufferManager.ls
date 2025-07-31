
  do ->

    { create-screen-buffer } = dependency 'tui.console.ScreenBuffer'
    { create-instance } = dependency 'reflection.Instance'
    { get-timestamp } = dependency 'unsafe.Date'

    create-id = -> "screen-buffer-#{ get-timestamp! }"

    create-screen-buffer-manager = ->

      screen-buffers = {}

      create-instance do

        create-screen-buffer: member: ->

          id = create-id! ; screen-buffer = create-screen-buffer!

          screen-buffers[ id ] := screen-buffer

          id

        get-screen-buffer: member: (id) -> screen-buffers[id]

    {
      create-screen-buffer-manager
    }