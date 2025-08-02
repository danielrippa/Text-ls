
  do ->

    { analyze-hresult } = dependency 'os.win32.HResult'

    { create-screen-buffer-manager } = dependency 'ScreenBufferManager'
    { create-application-log } = dependency 'ApplicationLog'
    { create-console-input } = dependency 'os.win32.com.ConsoleInput'

    { type } = dependency 'reflection.Type'

    { value-as-string } = dependency 'reflection.Value'

    application-module = (application) ->

      get-commands: -> ApplicationExit: -> application.quit!

    create-screen-buffer = (screen-buffer-manager) ->

      screen-buffer-manager => id = ..create-screen-buffer! ; return ..get-screen-buffer-by-id id

    startup = ({ execution, background-processing, application }) ->

      execution

        .. <<< input-events: create-console-input!

      background-processing

        .. <<< screen-buffers: create-screen-buffer-manager!
        .. <<< application-log: create-application-log create-screen-buffer ..screen-buffers ; ..application-log.start!
        .. <<< command-manager: create-commands-manager!

      { command-manager } = background-processing

      for module-name, module of background-processing with application-module application

        { get-commands } = module ; continue if get-commands is void

        for command-name, command of get-commands!

          command-manager.register-command command-name, command

    shutdown = ({ background-processing }) ->

      { application-log } = background-processing ; application-log.stop!

    before-execution = ({ execution }) ->

      { input-events: console-input } = execution ; input-event = eval "(#{ console-input.GetInputEvent! })"

      execution <<< { input-event }

    after-execution = -> coso

    failure = ({ error, context: { background-processing } }) ->

      { application-log } = background-processing ; application-log.write-error error

    {
      startup, shutdown,
      before-execution, after-execution,
      failure
    }