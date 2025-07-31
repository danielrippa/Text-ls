
  do ->

    { argv } = dependency 'os.shell.ScriptArgs'

    { create-command-manager } = dependency 'CommandManager'
    { create-document-manager } = dependency 'DocumentManager'
    { create-component-manager } = dependency 'ComponentManager'
    { create-screen-buffer-manager } = dependency 'ScreenBufferManager'
    { create-application-log } = dependency 'ApplicationLog'
    { create-splash-screen } = dependency 'Splash'

    subsystems-setup = (subsystems) ->

      { commands: command-manager } = subsystems

      for subsystem-name, subsystem of subsystems

        { get-commands } = subsystem ; continue if get-commands is void

        commands = get-commands!
        for command-name, command-function of commands
          command-manager.register-command { name: command-name, function: command-function }

    get-subsystems = ({ context }) ->

      subsystems = {}

        .. <<< commands: create-command-manager '.'
        .. <<< documents: create-document-manager argv
        .. <<< components: create-component-manager!
        .. <<< screen-buffers: create-screen-buffer-manager!
        .. <<< log: create-application-log ..screen-buffers
        .. <<< splash-screen: create-splash-screen ..screen-buffers

        subsystems-setup ..

      context <<< { subsystems }

      subsystems

    {
      get-subsystems
    }