
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { kebab-case } = dependency 'unsafe.StringCase'
    { map-array-items } = dependency 'unsafe.Array'
    { object-member-names } = dependency 'unsafe.Object'
    { function-execute-with-arguments: execute } = dependency 'unsafe.Function'
    { argument-type: argtype } = dependency 'reflection.ArgumentType'
    { error-from-value } = dependency 'reflection.Error'
    { value-as-string } = dependency 'reflection.Value'
    { string-split-at-index } = dependency 'unsafe.String'
    { debug } = dependency 'os.shell.IO'

    registration-error = -> new Error "Unable to register command. #it"

    execution-error = -> new Error "Unable to execute command. #it"

    disambiguate-command-name = (command-string, commands, aliases) ->

      [ prefix, command ] = command-string `string-split-at-index` 1

      switch prefix

        | '/' => 
          return command if commands[command]?
          void

        | '.' => 
          if aliases[command]?
            canonical-name = aliases[command]
            disambiguate-command-name "/#canonical-name", commands, aliases
          else
            void

        else throw new Error "Invalid command '#command-string'. Commands must start with either of '/' or '.'"

    create-command-manager = ->

      commands = {} ; command-aliases = {}

      instance = create-instance do

        register-command: member: (canonical-name, command) ->

          try argtype '< String >' {canonical-name} ; argtype '< Function >' {command}
          catch error => throw registration-error error-from-value error

          throw registration-error "Another command with canonical name '#canonical-name' was already registered" \
            if (kebab-case canonical-name) in map-array-items (object-member-names commands), kebab-case

          commands[ canonical-name ] := command

          debug "Registered command #canonical-name"

        register-command-alias: member: (canonical-command-name, alias) ->

          try argtype '< String >' {canonical-command-name} ; argtype '< String >' {alias}
          catch error => throw registration-error error-from-value error

          throw registration-error "No command registered with name '#canonical-command-name'" \
            unless commands[ canonical-command-name ]?

          throw registration-error "Alias '#alias' is already registered to '#{ command-aliases[ alias ] }'" \
            if command-aliases[ alias ]?

          command-aliases[alias] := canonical-command-name

          debug "Registered command alias '#alias' for command '#canonical-command-name'"

        execute-command: member: (command-name, command-arguments = []) ->

          try argtype '< String >' {command-name} ; argtype '< Array >' {command-arguments}
          catch error => throw execution-error value-as-string error-from-value error

          canonical-name = disambiguate-command-name command-name, commands, command-aliases

          throw execution-error "No command registered with the command name or alias '#command-name'" \
            if canonical-name is void

          command = commands[ canonical-name ]

          try result = execute command, command-arguments
          catch error => throw execution-error "Command name: '#command-name' (canonical name: '#canonical-name'). Error: #{ value-as-string error-from-value error }"

          result

        get-commands: member: ->

          CommandRegister: -> instance.register-command ...
          CommandRegisterAlias: -> instance.register-command-alias ...
          CommandExecute: (command-name, ...args) -> 
            # Add / prefix if command doesn't start with / or .
            formatted-command = if command-name.0 in ['/', '.'] then command-name else "/#command-name"
            instance.execute-command formatted-command, args

    {
      create-command-manager
    }