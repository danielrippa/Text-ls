
  do ->

    { create-instance } = dependency 'reflection.Instance'

    draw-application-splash-screen = (screen-buffer) ->

      screen-buffer

        ..goto 5 5 ; ..write 'Text editor'

    create-splash-screen = (screen-buffers) ->

      screen-buffer-id = screen-buffers.create-screen-buffer!

      get-screen-buffer = -> screen-buffers.get-screen-buffer screen-buffer-id

      instance = create-instance do

        activate: member: -> get-screen-buffer!activate!

        get-commands: member: ->

          SplashScreenActivate: -> instance.activate!

      draw-application-splash-screen get-screen-buffer!

      instance

    {
      create-splash-screen
    }