# Decimate

Discipline your file-system by selectively securely deleting some of it's precious files or directories.

Noteable features:

 - Endeavors to prevent you from accidentally rm -rfing your root dir
 - Uses shred utility to securely delete files, before removing
 - Allows additional sanity checking of paths

### Usage

    file_path = '/my_app/bad_file.txt'
    dir_path = '/my_app'

    Decimate.file file_path   # specified file shredded, deleted
    Decimate.dir dir_path    # all files in all sub-directories shredded, rm -rf the directory

Decimate.file, true to it's name, expects a file and will raise if it does not get one.  Likewise for Decimate.dir.

Ruby's File.expand_path is used to check give files or directories, in an attempt to suss out relative paths that might lead to a dangerous delete. 

As an additional sanity check, you can pass a regex pattern using the optional parameter path_must_match:

    Decimate.file file_path, path_must_match: /my_app/

After the file path is expanded, Decimate will raise if the resulting path does not match the given pattern.

### Caveats

 - The gem shells out to shred.  If shred is not installed, an error will be raised.
 - Decimate has been tested on Ubuntu Linux.  It probably won't work on Windows-based systems.
 - Decimate is not omniscient, it only tries to prevent you from blowing away the root directory, and whatever reasonable .  If you tell it to delete /bin/bash, it will do it.

Code reviews, comments, violent reactions welcome.  I highly encourage you to read over the gems short source and unit tests so you are comfortable with what it does before putting it into production.

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
