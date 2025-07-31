
  do ->

    { create-console-input } = dependency 'os.win32.com.ConsoleInput'
    { get-subsystems } = dependency 'SubSystems'

    startup = ({ context }) ->

      subsystems = get-subsystems { context }

      { splashScreen } = subsystems

      splashScreen.activate! 
      
      console-input = create-console-input! ; event-handling = { console-input }

      context <<< { event-handling, subsystems }

    shutdown = ->

      WScript.Echo 'shutdown'

    before-execution = ({ context: { event-handling } }) ->

      { console-input } = event-handling

      input-event = eval "(#{ console-input.GetInputEvent! })"

      switch input-event.type

        | 'WindowFocus' => { focused: is-window-focused } = input-event ; event-handling <<< { is-window-focused }

      event-handling <<< { input-event }

    after-execution = ->


    on-error = ({ error, application }) -> WScript.Echo error.message ; application.quit!

    {
      startup, shutdown, before-execution, after-execution, on-error
    }