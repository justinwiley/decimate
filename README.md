# Decimate

[![Build Status](https://secure.travis-ci.org/justinwiley/decimate.png)](http://travis-ci.org/justinwiley/decimate.png)

Discipline your file system by securely deleting some of its precious files or directories using shred.

### Notable features:

 - Uses shred utility to securely delete files, before removing
 - Allows additional sanity checking of paths
 - Endeavors to prevent you from accidentally rm -rfing your root dir

### Usage

    file_path = '/my_app/bad_file.txt'
    dir_path = '/my_app'

    Decimate.file! file_path   # specified file shredded, deleted
    Decimate.dir! dir_path    # all files in all sub-directories shredded, rm -rf the directory

If the file or dir does not exist, it will return nil without doing anything.  Both file! an dir! return the standard out of the executed command (shred) if success.  If the shred command fails (or find, which executes shred) and returns any other status code besides 0, an exception will be raised.

Ruby's File.expand_path is used to check give files or directories, in an attempt to suss out relative paths that might lead to a dangerous delete. 

As an additional sanity check, you can pass a regex pattern using the optional parameter path_must_match:

    Decimate.file file_path, path_must_match: /my_app/

After the file path is expanded, Decimate will raise if the resulting path does not match the given pattern.

See RDoc for details.

### Caveats

 - *Do not feed it raw params from a web-request*.  You should carefully white-list anything that comes in.
 - Since this proxies to the underlying operating system, and returns silently if the file or directory to be deleted no longer exist, I assume this is thread-safe, but no guarantees.
 - The gem shells out to shred.  If shred is not installed, an error will be raised.
 - Since it's shredding files, disk-recovery utilities won't save you if you accidentally delete something.
 - Shred has many limitations, especially on journaling file systems, see the man page.
 - The find command is executed with the -exec option instead of -execdir due to issues with some build environments.  This is theoretically less secure.  Read the man page for security implications.
 - Decimate has been tested on Ubuntu Linux.  It won't work on Windows-based systems.
 - Decimate has few scruples, it only tries to prevent you from blowing away the root directory, and whatever regex you provide.  If you tell it to delete /bin/bash, it will do it.

Code reviews, comments, violent reactions welcome.

### Installation

Add this line to your application's Gemfile:

    gem 'decimate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install decimate

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
