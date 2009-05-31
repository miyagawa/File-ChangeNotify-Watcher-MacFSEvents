use inc::Module::Install;
name 'File-ChangeNotify-Watcher-MacFSEvents';
all_from 'lib/File/ChangeNotify/Watcher/MacFSEvents.pm';

requires 'File::ChangeNotify';
requires 'Mac::FSEvents';

build_requires 'Test::More';
use_test_base;
auto_include_deps;
author_tests('xt');
auto_set_repository;
WriteAll;
