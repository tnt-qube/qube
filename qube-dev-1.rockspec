package = 'qube'
version = 'dev-2'
source = {
  url = 'git://github.com/tnt-qube/qube.git',
  branch = 'master',
}

description = {
  summary = 'API layer over Tarantool Queue via HTTP',
  homepage = 'https://github.com/tnt-qube',
  license  = 'MIT'
}
dependencies = {
  'lua >= 5.1'
}

build = {
  type = 'builtin',
  modules = {
    ['qube'] = 'qube/init.lua',
  }
}