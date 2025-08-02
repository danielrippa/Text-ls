
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { kebab-case } = dependency 'unsafe.StringCase'
    { map-array-items } = dependency 'unsafe.Array'
    { object-member-names } = dependency 'unsafe.Object'
    { function-execute-with-arguments: execute } = dependency 'unsafe.Function'
    { argument-type: argtype } = dependency 'reflection.ArgumentType'

    registration-error = -> new Error "Unable to register command. #it"

    execution-error = -> new Error "Unable to execute command. #it"

    disambiguate-command-name = (command-name, commands, aliases) ->

    create-command-manager = ->

      commands = {} ; command-aliases = {}

      instance = create-instance do

        register-command: member: (canonical-name, command) ->

          try argtype '< String >' {canonical-name} ; argtype '< Function >' {command}
          catch error => throw registration-error error-from-value error

          throw registration-error "Another command with canonical name '#canonical-name' was already registered" \
            if (kebab-case canonical-name) in map-array-items (object-member-names commands), kebab-case

          commands[ canonical-name ] := command

        register-command-alias: member: (command-name, alias) ->

          try argtype '< String >' {command-name} ; argtype '< String >' {alias}

        execute-command: member: (command-name, command-arguments = []) ->

          try argtype '< String >' {command-name} ; argtype '< Array >' {command-arguments}
          catch error => throw execution-error error-from-value error

          canonical-name = disambiguate-command-name command-name command-name, commands, command-aliases

          throw execution-error "No command was registered with the command name or alias '#command-name'" \
            if canonical-name is void

          command = commands[ canonical-name ]

          try result = execute command, parameters
          catch error => throw execution-error "Command name: '"command-name' (canonical name: '#canonical-name'). Error: #{ value-as-string error-from-value error }"

          result

        get-commands: member: ->

          RegisterCommand: -> instance.register-command ...
          RegisterCommandAlias: -> instance.register-command-alias ...
          ExecuteCommand: -> instance.execute-command ...

    {
      create-command-manager
    }