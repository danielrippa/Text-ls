
  do ->

    { sleep } = dependency 'os.shell.Script'

    cpu-throttling-setup = ({ execution, background-processing }) ->

      activity-cycles = 0
      last-processed-event = null
      
      execution.get-execution-statistics-analysis = (context) ->
        
        { execution, background-processing } = context
        
        has-input = execution.input-event?.type? and execution.input-event.type isnt 'None'
        
        has-mailslot = no
        try
          has-mailslot = background-processing.incoming-commands-reader?.has-pending-commands?!
        catch
          has-mailslot = no
        
        if has-input or has-mailslot
          activity-cycles = 0
        else
          activity-cycles++
        
        foreground-time = if execution.start? and execution.end? then execution.end - execution.start else 0
        background-time = if background-processing.start? and background-processing.end? then background-processing.end - background-processing.start else 0
        
        {
          activity-cycles: activity-cycles
          has-input: has-input
          has-mailslot: has-mailslot
          foreground-time: foreground-time
          background-time: background-time
        }
      
      execution.throttling-algorithm = (analysis, context) ->
        
        activity-cycles = analysis.activity-cycles or 0
        has-input = analysis.has-input
        has-mailslot = analysis.has-mailslot
        foreground-time = analysis.foreground-time or 0
        background-time = analysis.background-time or 0
        
        total-time = foreground-time + background-time
        
        sleep-time = if has-input
          0
        else if has-mailslot
          1
        else if activity-cycles < 25
          if total-time > 5 then 2 else 1
        else if activity-cycles < 100
          if total-time > 10 then 8 else 5
        else if activity-cycles < 500
          if total-time > 15 then 25 else 15
        else
          if total-time > 20 then 50 else 40
        
        sleep sleep-time


    {
      cpu-throttling-setup
    }