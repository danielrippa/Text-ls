
  { create-application } = dependency 'tui.Application'

  { startup, shutdown, failure } = dependency 'Execution'
  { before-execution, after-execution, background-processing } = dependency 'BackgroundProcessing'

  create-application!

    ..on-startup startup ; ..on-shutdown shutdown

    ..before-execution before-execution ; ..after-execution after-execution ; ..on-error failure

    ..on-idle background-processing

    ..start ({ execution, application }) ->

      { input-event } = execution

      switch input-event.type

        | 'KeyPressed' =>

          WScript.StdOut.Write input-event.ascii-char

          switch input-event.ascii-char

            | 'q' => 
              
              application.quit!

