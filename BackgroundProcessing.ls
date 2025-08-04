
  do ->

    { value-as-string } = dependency 'reflection.Value'
    { sleep } = dependency 'os.shell.Script'
    { cpu-throttling-setup } = dependency 'CpuThrottling'

    background-processing-setup = ({ execution, background-processing }) ->

      cpu-throttling-setup { execution, background-processing }

    before-execution = ({ execution }) ->

      { console-input } = execution ; console-input.fire-events!

    after-execution = ({ execution }) ->

    background-processing = ({ execution, background-processing }) ->

      delete execution.input-event

      { command-manager, incoming-commands-reader } = background-processing

      if incoming-commands-reader.has-pending-commands!

        [ command-name, command-arguments ] = incoming-commands-reader.read-command!

        command-manager.execute-command command-name, command-arguments

    {
      background-processing-setup,
      before-execution, after-execution,
      background-processing
    }