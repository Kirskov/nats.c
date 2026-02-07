# Test suite
testsuite_sources = files(
  'test.c',
  'bench_sub_async.c',
)

testsuite = executable('testsuite',
  testsuite_sources,
  dependencies: nats_build_lib_static ? nats_static_dep : nats_dep,
  include_directories: include_directories('../src'),
  install: false,
)

# Read test lists
test_list = files('list_test.txt')
bench_list = files('list_bench.txt')

# Function to parse and add tests from a list file
parse_test_list = '''
import sys
import re

list_file = sys.argv[1]
test_type = sys.argv[2]  # 'test' or 'bench'

with open(list_file, 'r') as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('#'):
            # Extract test name from _test(name) format
            match = re.match(r'_test\(([^)]+)\)', line)
            if match:
                test_name = match.group(1)
                print(f'{test_name}')
'''

# Add regular tests
if test_list[0].found()
  test_names_output = run_command('python3', '-c', parse_test_list,
    meson.current_source_dir() / 'list_test.txt', 'test',
    check: false)

  if test_names_output.returncode() == 0
    test_names = test_names_output.stdout().strip().split('\n')
    foreach test_name : test_names
      if test_name != ''
        test(test_name, testsuite,
          args: [test_name],
          workdir: meson.current_source_dir(),
          suite: 'nats',
        )
      endif
    endforeach
  endif
endif

# Add benchmarks (if enabled)
if get_option('benchmarks')
  if bench_list[0].found()
    bench_names_output = run_command('python3', '-c', parse_test_list,
      meson.current_source_dir() / 'list_bench.txt', 'bench',
      check: false)

    if bench_names_output.returncode() == 0
      bench_names = bench_names_output.stdout().strip().split('\n')
      foreach bench_name : bench_names
        if bench_name != ''
          test(bench_name, testsuite,
            args: [bench_name],
            workdir: meson.current_source_dir(),
            suite: 'bench',
            is_parallel: false,
          )
        endif
      endforeach
    endif
  endif
endif

# Add streaming tests (if streaming is enabled)
if nats_build_streaming
  stan_list = files('list_stan.txt')
  if stan_list[0].found()
    stan_names_output = run_command('python3', '-c', parse_test_list,
      meson.current_source_dir() / 'list_stan.txt', 'test',
      check: false)

    if stan_names_output.returncode() == 0
      stan_names = stan_names_output.stdout().strip().split('\n')
      foreach stan_name : stan_names
        if stan_name != ''
          test(stan_name, testsuite,
            args: [stan_name],
            workdir: meson.current_source_dir(),
            suite: 'stan',
          )
        endif
      endforeach
    endif
  endif
endif
