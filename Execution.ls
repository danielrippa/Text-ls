
  do ->

    { analyze-hresult } = dependency 'os.win32.HResult'
    { create-screen-buffer-manager } = dependency 'ScreenBufferManager'
    { create-application-log } = dependency 'ApplicationLog'
    { create-console-input } = dependency 'os.win32.com.ConsoleInput'
    { create-mailslot-command-reader } = dependency 'MailslotCommandReader'
    { create-command-manager } = dependency 'CommandManager'
    { type } = dependency 'reflection.Type'
    { value-as-string } = dependency 'reflection.Value'
    { fail } = dependency 'os.shell.Script'
    { error-from-value } = dependency 'reflection.Error'
    { stderr } = dependency 'os.shell.IO'
    { sleep } = dependency 'os.shell.Script'
    { background-processing-setup } = dependency 'BackgroundProcessing'

    application-module = (application) ->

      get-commands: -> ApplicationExit: -> application.quit!

    create-screen-buffer = (screen-buffer-manager) ->
      screen-buffer-manager => id = ..create-screen-buffer! ; return ..get-screen-buffer-by-id id

    startup = ({ execution, background-processing, application }) ->

      background-processing-setup { execution, background-processing }

      execution

        .. <<< input-events: create-console-input!

      background-processing

        .. <<< screen-buffers: create-screen-buffer-manager!
        .. <<< application-log: create-application-log create-screen-buffer ..screen-buffers ; ..application-log.start!
        .. <<< command-manager: create-command-manager!
        .. <<< incoming-commands-reader: create-mailslot-command-reader! ; ..incoming-commands-reader.start!
        .. <<< application: application-module application

      { command-manager } = background-processing

      for module-name, module of background-processing

        { get-commands } = module ; continue if get-commands is void

        for command-name, command of get-commands!

          command-manager.register-command command-name, command

    shutdown = ({ background-processing }) ->

      { application-log } = background-processing ; application-log.stop!

    failure = ({ error, context: { background-processing } }) ->

      { application-log } = background-processing ; application-log.write-error error ; stderr value-as-string error

    {
      startup, shutdown,
      before-execution, after-execution,
      failure
    }