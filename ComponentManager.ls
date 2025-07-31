
  do ->

    { create-instance } = dependency 'reflection.Instance'

    create-component-commands = ->

      [
        ComponentCreate: -> [ "#args" for arg in arguments ] * '' |> WScript.Echo
      ]

    create-component-manager = ->

      component-commands = create-component-commands!

      create-instance do

        get-commands: member: -> component-commands



    {
      create-component-manager
    }