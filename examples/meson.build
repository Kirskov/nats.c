# Determine which nats dependency to use for examples
if get_option('static_examples')
  if not nats_build_lib_static
    error('static_examples=true requires building static library (use -Ddefault_library=static or -Ddefault_library=both)')
  endif
  examples_nats_dep = nats_static_dep
else
  examples_nats_dep = nats_dep
endif

# Basic examples
basic_examples = [
  'asynctimeout',
  'connect',
  'publisher',
  'queuegroup',
  'replier',
  'requestor',
  'subscriber',
]

foreach example : basic_examples
  executable(example,
    example + '.c',
    dependencies: examples_nats_dep,
    install: false,
  )
endforeach

# JetStream examples
js_examples = [
  'js-pub',
  'js-sub',
]

foreach example : js_examples
  executable(example,
    example + '.c',
    dependencies: examples_nats_dep,
    install: false,
  )
endforeach

# Micro examples
micro_examples = [
  'micro-arithmetics',
  'micro-func',
  'micro-hello',
  'micro-sequence',
  'micro-stats',
]

foreach example : micro_examples
  executable(example,
    example + '.c',
    dependencies: examples_nats_dep,
    install: false,
  )
endforeach

# Libevent examples (optional)
if get_option('build_libevent_examples')
  libevent_dep = dependency('libevent', required: true)
  executable('libevent-pub',
    'libevent-pub.c',
    dependencies: [examples_nats_dep, libevent_dep],
    install: false,
  )
  executable('libevent-sub',
    'libevent-sub.c',
    dependencies: [examples_nats_dep, libevent_dep],
    install: false,
  )
endif

# Libuv examples (optional)
if get_option('build_libuv_examples')
  libuv_dep = dependency('libuv', required: true)
  executable('libuv-pub',
    'libuv-pub.c',
    dependencies: [examples_nats_dep, libuv_dep],
    install: false,
  )
  executable('libuv-sub',
    'libuv-sub.c',
    dependencies: [examples_nats_dep, libuv_dep],
    install: false,
  )
endif

# Getstarted examples
subdir('getstarted')
