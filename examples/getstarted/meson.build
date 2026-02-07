# Getstarted examples
getstarted_examples = [
  'asyncsub',
  'headers',
  'pubbytes',
  'pubmsg',
  'pubstr',
  'replier',
  'requestor',
  'syncsub',
]

foreach example : getstarted_examples
  executable('getstarted-' + example,
    example + '.c',
    dependencies: examples_nats_dep,
    install: false,
  )
endforeach
