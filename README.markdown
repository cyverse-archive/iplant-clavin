# IPlant::Clavin

IPlant::Clavin is a Perl extension that can be used to retrieve configuration
settings from iPlant's Zookeeper cluster.

## Installation

The installation of IPlant::Clavin itself is relatively simple, but installing
one of its dependencies, `Net::ZooKeeper`, is not.  So far, the easiest way
that I've found to install `Net::ZooKeeper` is to download the source tarball
from CPAN and install it manually.  Before doing that, however, you have to
ensure that a C compiler is installed and know the path to the Zookeeper
client library and its include files.  In my experience, the files are
installed somewhere in the `/usr` directory tree, so a couple of `find`
commands should be enough to find these files.  On Linux systems, something
like this should work:

```
$ find /usr -name zookeeper_version.h | head -1 | xargs dirname
$ find /usr -name libzookeeper*.so | head -1 | xargs dirname
```

You'll probably want to run these commands separately rather than using
command substitution in case Zookeeper is not installed or is installed under
a different directory tree.  Once you have this information, you're ready to
install Zookeeper.  If you do need to install Zookeeper on a RedHat compatible
system, you can use `yum`:

```
$ yum install zookeeper-lib
```

Assuming that the include directory is `/usr/include/zookeeper` and the
libraries are installed in `/usr/lib`, these commands should be enough to
install `Net::Zookeeper`:

```
$ wget http://search.cpan.org/CPAN/authors/id/C/CD/CDARROCH/Net-ZooKeeper-0.35.tar.gz
$ tar xvf Net-ZooKeeper-0.35.tar.gz
$ cd Net-ZooKeeper-0.35
$ perl Makefile.PL --zookeeper-include=/usr/include/zookeeper --zookeeper-lib=/usr/lib
$ make
$ sudo make install
```

Once _that's_ done, you can install IPlant::Clavin using the normal commands:

```
$ perl Makefile.PL
$ make
$ sudo make install
```

## Support and Documentation

After installing, you can find documentation for this module with the
perldoc command.

```
$ perldoc IPlant::Clavin
```

## License and Copyright

Copyright (c) 2012, The Arizona Board of Regents on behalf of The University
of Arizona

All rights reserved.

Developed by: iPlant Collaborative at BIO5 at The University of Arizona
http://www.iplantcollaborative.org

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of the iPlant Collaborative, BIO5, The University of
   Arizona nor the names of its contributors may be used to endorse or promote
   products derived from this software without specific prior written
   permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
