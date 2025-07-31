
  { create-application } = dependency 'tui.Application'

  { startup, before-execution, after-execution, shutdown, on-error } = dependency 'Execution'
  { background-processing } = dependency 'Background'

  char = (.ascii-char-string)

  create-application!

    ..on-startup startup ; ..on-shutdown shutdown ; ..on-error on-error

    ..before-execution before-execution ; ..after-execution after-execution

    ..on-idle background-processing

    ..start ({ context: { subsystems: { commands }, event-handling: { input-event } }, application: { quit } }) ->

      switch input-event.type

        | 'KeyPressed' =>

          key = char input-event

          switch key

            | 'q' => quit!

            | 's' => commands.execute 'SplashScreenActivate'

            | 'l' => commands.execute 'ApplicationLogActivate'
            | 'w' => commands.execute 'ApplicationLogWrite', 'testing'
            | 'g' => commands.execute 'ApplicationLogGotoLastLine'
