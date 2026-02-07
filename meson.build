project('cnats', 'c',
  version: '3.13.0-beta',
  license: 'Apache-2.0',
  default_options: [
    'c_std=c99',
    'warning_level=2',
    'buildtype=release',
  ],
  meson_version: '>=1.3.2'
)

# Version information
version_array = meson.project_version().split('-')
version_base = version_array[0].split('.')
version_major = version_base[0].to_int()
version_minor = version_base[1].to_int()
version_patch = version_base[2].to_int()
version_suffix = version_array.length() > 1 ? '-' + version_array[1] : ''
version_required_number = '0x030B00'

# Platform detection
host_system = host_machine.system()
is_windows = host_system == 'windows'
is_darwin = host_system == 'darwin'
is_linux = host_system == 'linux'

# Project options
nats_build_with_tls = get_option('tls')
nats_build_tls_force_host_verify = get_option('tls_force_host_verify')
nats_build_streaming = get_option('streaming')
nats_build_use_sodium = get_option('use_sodium')
nats_build_examples = get_option('examples')
nats_build_lib_static = get_option('default_library') in ['static', 'both']
nats_build_lib_shared = get_option('default_library') in ['shared', 'both']
nats_build_no_spin = get_option('no_spin')
nats_build_no_prefix_connsts = get_option('no_prefix_connsts')
nats_with_experimental = get_option('experimental')
nats_compiler_hardening = get_option('compiler_hardening')
nats_coverage = get_option('b_coverage')

# Compile definitions
compile_args = []
compile_args += '-D_REENTRANT'

if is_windows
  compile_args += '-D_WIN32'
elif is_darwin
  compile_args += '-DDARWIN'
elif is_linux
  compile_args += '-DLINUX'
  compile_args += '-D_GNU_SOURCE'
  if nats_build_no_spin
    compile_args += '-DNATS_NO_SPIN'
  endif
endif

if nats_build_with_tls
  compile_args += '-DNATS_HAS_TLS'
  if nats_build_tls_force_host_verify
    compile_args += '-DNATS_FORCE_HOST_VERIFICATION'
  endif
endif

if nats_build_streaming
  compile_args += '-DNATS_HAS_STREAMING'
endif

if nats_build_use_sodium
  compile_args += '-DNATS_USE_LIBSODIUM'
endif

if nats_build_no_prefix_connsts
  compile_args += '-DNATS_CONN_STATUS_NO_PREFIX'
endif

if nats_with_experimental
  compile_args += '-DNATS_WITH_EXPERIMENTAL'
endif

# Compiler flags
c_compiler = meson.get_compiler('c')
warning_flags = []

if is_windows
  if c_compiler.get_id() == 'msvc'
    warning_flags += ['/W4', '/wd4100', '/wd4200', '/wd4130', '/wd4127']
  else
    warning_flags += [
      '-Wall',
      '-Wextra',
      '-Wno-unused-parameter',
      '-Wno-pedantic',
      '-Wno-address',
      '-Wno-constant-conditional'
    ]
  endif
else
  warning_flags += [
    '-fstrict-aliasing',
    '-Wall',
    '-W',
    '-Wno-unused-parameter',
    '-Wno-unused-function',
    '-Wstrict-prototypes',
    '-Wwrite-strings'
  ]

  if nats_compiler_hardening
    # Note: Don't add -fPIE here for libraries (will cause issues with shared libs)
    # We'll add it to executables separately
    warning_flags += [
      '-fstack-protector-all',
      '-D_FORTIFY_SOURCE=2',
    ]
  endif
endif

# Filter supported warning flags
supported_warning_flags = []
foreach flag : warning_flags
  if c_compiler.has_argument(flag)
    supported_warning_flags += flag
  endif
endforeach

compile_args += supported_warning_flags

# Linker flags (separate from compile flags)
link_flags = []
link_flags_exe = []  # For executables only
if not is_windows and nats_compiler_hardening
  if c_compiler.get_id() == 'gcc'
    # Relro/now for both libraries and executables
    if c_compiler.has_link_argument('-Wl,-z,relro,-z,now')
      link_flags += ['-Wl,-z,relro,-z,now']
      link_flags_exe += ['-Wl,-z,relro,-z,now']
    endif
    if c_compiler.has_link_argument('-pie')
      link_flags_exe += ['-pie']
    endif
  endif
endif

# Dependencies
thread_dep = dependency('threads')
deps = [thread_dep]

# OpenSSL/TLS dependency
if nats_build_with_tls
  openssl_dep = dependency('openssl', version: '>=1.1.1', required: true)
  deps += openssl_dep
endif

# Platform-specific dependencies
if is_windows
  deps += c_compiler.find_library('ws2_32')
elif is_linux and not get_option('android')
  deps += c_compiler.find_library('rt', required: false)
endif

# Optional dependencies
if nats_build_streaming
  protobuf_c_dep = dependency('libprotobuf-c', required: true)
  deps += protobuf_c_dep
endif

if nats_build_use_sodium
  sodium_dep = dependency('libsodium', required: true)
  deps += sodium_dep
endif

# Source files
src_dir = 'src'
platform_dir = is_windows ? 'src/win' : 'src/unix'

# Gather source files
sources = files(
  'src/asynccb.c',
  'src/buf.c',
  'src/comsock.c',
  'src/conn.c',
  'src/crypto.c',
  'src/dispatch.c',
  'src/hash.c',
  'src/js.c',
  'src/jsm.c',
  'src/kv.c',
  'src/micro.c',
  'src/micro_client.c',
  'src/micro_endpoint.c',
  'src/micro_error.c',
  'src/micro_monitoring.c',
  'src/micro_request.c',
  'src/msg.c',
  'src/nats.c',
  'src/natstime.c',
  'src/nkeys.c',
  'src/nuid.c',
  'src/object.c',
  'src/opts.c',
  'src/parser.c',
  'src/pub.c',
  'src/srvpool.c',
  'src/stats.c',
  'src/status.c',
  'src/sub.c',
  'src/timer.c',
  'src/url.c',
  'src/util.c',
)

# Platform-specific sources
if is_windows
  sources += files(
    'src/win/cond.c',
    'src/win/mutex.c',
    'src/win/sock.c',
    'src/win/strings.c',
    'src/win/thread.c',
  )
else
  sources += files(
    'src/unix/cond.c',
    'src/unix/mutex.c',
    'src/unix/sock.c',
    'src/unix/thread.c',
  )
endif

# GLIB sources
sources += files(
  'src/glib/glib.c',
  'src/glib/glib_async_cb.c',
  'src/glib/glib_dispatch_pool.c',
  'src/glib/glib_gc.c',
  'src/glib/glib_last_error.c',
  'src/glib/glib_ssl.c',
  'src/glib/glib_timer.c',
)

# Streaming sources
if nats_build_streaming
  sources += files(
    'src/stan/conn.c',
    'src/stan/copts.c',
    'src/stan/msg.c',
    'src/stan/protocol.c',
    'src/stan/pub.c',
    'src/stan/sopts.c',
    'src/stan/stan.c',
    'src/stan/sub.c',
  )
endif

# Include directories
inc_dirs = include_directories(
  'src',
  'src/include',
  'src/glib',
  platform_dir,
)

# Generate version.h from template
version_h_conf = configuration_data()
version_h_conf.set('NATS_VERSION_MAJOR', version_major)
version_h_conf.set('NATS_VERSION_MINOR', version_minor)
version_h_conf.set('NATS_VERSION_PATCH', version_patch)
version_h_conf.set('NATS_VERSION_SUFFIX', version_suffix)
version_h_conf.set('NATS_VERSION_STRING', '@0@.@1@.@2@@3@'.format(version_major, version_minor, version_patch, version_suffix))
version_h_conf.set('NATS_VERSION_REQUIRED_NUMBER', version_required_number)

version_h = configure_file(
  input: 'src/version.h.in',
  output: 'version.h',
  configuration: version_h_conf,
  install: true,
  install_dir: get_option('includedir') / 'nats'
)

# Library targets
# Note: link_flags contains relro/now, link_flags_exe also has -pie for executables
nats_link_args = []
nats_static_link_args = []

# Add relro/now but NOT -pie (which is for executables only)
if not is_windows and nats_compiler_hardening and c_compiler.get_id() == 'gcc'
  if c_compiler.has_link_argument('-Wl,-z,relro,-z,now')
    nats_link_args += ['-Wl,-z,relro,-z,now']
    nats_static_link_args += ['-Wl,-z,relro,-z,now']
  endif
endif

if is_darwin
  nats_link_args += ['-Wl,-rpath,@loader_path']
endif

# Static library
if nats_build_lib_static
  nats_static = static_library('nats',
    sources,
    version_h,
    include_directories: inc_dirs,
    c_args: compile_args + ['-DNATS_STATIC'],
    dependencies: deps,
    link_args: nats_static_link_args,
    install: true,
    pic: true,
  )

  nats_static_dep = declare_dependency(
    link_with: nats_static,
    include_directories: inc_dirs,
    compile_args: ['-DNATS_STATIC'],
    dependencies: deps,
  )
endif

# Shared library
if nats_build_lib_shared
  nats_shared = shared_library('nats',
    sources,
    version_h,
    include_directories: inc_dirs,
    c_args: compile_args,
    dependencies: deps,
    link_args: nats_link_args,
    version: '@0@.@1@.@2@'.format(version_major, version_minor, version_patch),
    soversion: '@0@.@1@'.format(version_major, version_minor),
    install: true,
    darwin_versions: ['@0@.@1@'.format(version_major, version_minor), '@0@.@1@.@2@'.format(version_major, version_minor, version_patch)],
  )

  nats_shared_dep = declare_dependency(
    link_with: nats_shared,
    include_directories: inc_dirs,
    dependencies: deps,
  )
endif

# Set the default dependency based on default_library option
if get_option('default_library') == 'static'
  nats_dep = nats_static_dep
elif get_option('default_library') == 'shared'
  nats_dep = nats_shared_dep
else
  # For 'both', prefer shared
  nats_dep = nats_shared_dep
endif

# Install headers
# Note: deprnats.h needs to be installed as nats.h
# We use a custom target to copy and rename the file
nats_h = custom_target('nats_h',
  input: 'src/deprnats.h',
  output: 'nats.h',
  command: [find_program('cp'), '@INPUT@', '@OUTPUT@'],
  install: true,
  install_dir: get_option('includedir')
)

install_headers(
  'src/nats.h',
  'src/status.h',
  install_dir: get_option('includedir') / 'nats'
)
install_headers(
  'src/adapters/libevent.h',
  'src/adapters/libuv.h',
  install_dir: get_option('includedir') / 'nats' / 'adapters'
)

# Generate pkg-config file
pkg = import('pkgconfig')
pkg.generate(
  name: 'libnats',
  description: 'NATS C Client with JetStream support',
  url: 'https://github.com/nats-io/nats.c',
  libraries: nats_build_lib_shared ? nats_shared : nats_static,
  version: meson.project_version(),
  subdirs: ['nats'],
)

# Examples
if nats_build_examples
  subdir('examples')
endif

# Tests
if get_option('tests')
  subdir('test')
endif

# Summary
summary({
  'Version': meson.project_version(),
  'TLS Support': nats_build_with_tls,
  'Streaming Support': nats_build_streaming,
  'Libsodium Support': nats_build_use_sodium,
  'Build Examples': nats_build_examples,
  'Build Tests': get_option('tests'),
  'Static Library': nats_build_lib_static,
  'Shared Library': nats_build_lib_shared,
  'Experimental API': nats_with_experimental,
}, section: 'Configuration')
