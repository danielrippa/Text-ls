
  do ->

    { create-instance } = dependency 'reflection.Instance'
    { create-screen-buffer } = dependency 'tui.console.ScreenBuffer'
    { get-timestamp: timestamp } = dependency 'unsafe.Date'

    create-document = (filepath) ->

      screen-buffer = create-screen-buffer!

      create-instance do

        screen-buffer: getter: -> screen-buffer

    create-document-manager = (filepaths) ->

      documents = {}

      document-manager = create-instance do

        add: member: (filepath) ->

          documents[ "doc-#{ timestamp! }" ] := create-document filepath

      for filepath in filepaths => document-manager.add filepath

      document-manager

    {
      create-document-manager
    }