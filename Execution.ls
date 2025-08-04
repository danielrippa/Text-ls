
  do ->

    { analyze-hresult } = dependency 'os.win32.HResult'
    { create-screen-buffer-manager } = dependency 'tui.console.ScreenBufferManager'
    { create-application-log } = dependency 'ApplicationLog'
    { create-mailslot-command-reader } = dependency 'MailslotCommandReader'
    { create-command-manager } = dependency 'CommandManager'
    { type } = dependency 'reflection.Type'
    { value-as-string } = dependency 'reflection.Value'
    { fail } = dependency 'os.shell.Script'
    { error-from-value } = dependency 'reflection.Error'
    { stderr } = dependency 'os.shell.IO'
    { sleep } = dependency 'os.shell.Script'
    { background-processing-setup } = dependency 'BackgroundProcessing'
    { create-input: create-console-input } = dependency 'tui.console.Input'

    application-module = (application) ->

      get-commands: -> ApplicationExit: -> application.quit!

    create-screen-buffer = (screen-buffer-manager) ->

      screen-buffer-manager => id = ..get-new-screen-buffer-id! ; ..get-screen-buffer-by-id id

    input-event-handler = (execution) -> (input-event) -> execution <<< { input-event }

    window-event-handler = (execution) -> (window-event) ->

      switch window-event.type

        | 'WindowFocus' => { focused: is-window-focused } = window-event ; execution <<< { is-window-focused }

    startup = ({ execution, background-processing, application }) ->

      background-processing-setup { execution, background-processing }

      execution

        .. <<< console-input: create-console-input!

        WScript.Echo ..console-input.mode-state!

        ..console-input

          ..on-mouse-event input-event-handler execution
          ..on-key-event   input-event-handler execution

          ..on-window-event window-event-handler execution

          application <<< { console-input-mode-state: ..mode-state! }

          ..enable-raw-mode!

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

    shutdown = ({ execution, background-processing, application }) ->

      { console-input } = execution ;
      { console-input-mode-state } = application ; WScript.Echo console-input-mode-state
      console-input.set-mode-state console-input-mode-state

      { application-log } = background-processing ; application-log.stop!

    failure = ({ error, context: { background-processing } }) ->

      { application-log } = background-processing ; # application-log.write-error error ;
      stderr value-as-string error

    {
      startup, shutdown,
      before-execution, after-execution,
      failure
    }