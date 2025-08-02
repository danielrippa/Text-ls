
  { create-application } = dependency 'tui.Application'

  { startup, shutdown, before-execution, after-execution, failure } = dependency 'Execution'
  { background-processing } = dependency 'BackgroundProcessing'

  create-application!

    ..on-startup startup ; ..on-shutdown shutdown

    ..before-execution before-execution ; ..after-execution after-execution ; ..on-error failure

    ..on-idle background-processing

    ..start ({ application }) -> application.quit!