currentTest = {}
startTime = null

QUnit.testStart (context) ->
  currentTest = {}
  currentTest.name = context.name
  currentTest.assertions = 0
  startTime = (new Date()).getTime()

QUnit.log (context) -> 
  if context.result
    currentTest.assertions++
    return

  stackTrace = []
  currentTest.backtrace = []

  # qunit handles exceptions in a werid way. It prepends "Died" 
  # to the stacktrace and shoves that in message
  if context.message.match(/^Died/)
    currentTest.error = true
    currentTest.message = context.source
    stackTrace = context.message

  # General Assertion Error
  else if context.message
    currentTest.assertions++
    currentTest.failed = true
    currentTest.message = context.message
    stackTrace = context.source

  # Failed expectations
  else if context.expected
    currentTest.failed = true
    currentTest.message = "Expected: #{context.expected}, Actual: #{context.actual}"
    stackTrace = context.source

  # format the backtrace accordingly
  for line in stackTrace.split("\n")
    matches = line.match(/(file|https?:\/\/.+:\d+)/)
    if matches
      currentTest.backtrace.push matches[1]
    else
      currentTest.backtrace.push line

QUnit.testDone (context) -> 
  currentTest.time = (new Date()).getTime() - startTime
  console.log("<iridium>#{JSON.stringify(currentTest)}</iridium>")

QUnit.done (context) ->
  console.log('done')
  window.qunitDone = true
