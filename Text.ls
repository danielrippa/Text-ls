
  { create-application } = dependency 'tui.Application'

  { startup, shutdown, failure } = dependency 'Execution'
  { before-execution, after-execution, background-processing } = dependency 'BackgroundProcessing'

  { value-as-string } = dependency 'reflection.Value'

  create-application!

    ..on-startup startup ; ..on-shutdown shutdown

    ..before-execution before-execution ; ..after-execution after-execution ; ..on-error failure

    ..on-idle background-processing

    ..start ({ execution, application }) ->

      { input-event } = execution ; return if input-event is void

      switch input-event.type

        | 'MouseMoved' => WScript.StdOut.Write '.'

        | 'KeyPressed' =>

          switch input-event.key-type

            | 'function' => WScript.Echo input-event.function-key

            else

              WScript.StdOut.Write input-event.ascii-char

              switch input-event.unicode-char

                | 'q' =>

                  application.quit!

        | 'None' =>

        else input-event.type