
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { kebab-case } = dependency 'unsafe.StringCase'
    { string-split-at-index } = dependency 'unsafe.String'

    disambiguate-command-name = (string) ->

      # checks wether this is a canonical name, an alias or an abbreviation, in that order

      # [ prefix, command-name ] = string string-split-at-index 1
      
      # For now, just return the string as-is
      string

    create-command-manager = (prefix) ->

      commands = {} ; command-aliases = {}

      create-instance do

        prefix: getter: -> prefix

        register-command: member: (command) ->

          commands[ command.name ] := command

        execute: member: (command-name, parameters) ->

          canonical-command-name = disambiguate-command-name command-name

          command = commands[ canonical-command-name ]

          if parameters
            command.function parameters
          else
            command.function!

    {
      create-command-manager
    }