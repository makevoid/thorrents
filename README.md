# Thorrents
## Take the torrent power back! Smash HTTP downloads! Thor agrees!

main code:
## https://github.com/makevoid/thorrents/blob/master/models/thorz.rb

usage:
## https://github.com/makevoid/thorrents/blob/master/thorrents.rb#L161

old domain:
[thorrents.com](http://thorrents.com)

The tHorrents are coming from tpb, that is still blocked in some countries like Italy, that's why this project makes some sense somewhere.

### JSON API Documentation

[thorrents.com/docs](http://thorrents.com/docs)

### Installation

note: you need ruby 1.9.x and the bundler gem installed

how to install:

clone the repo, install the dependencies and run

    git clone git://github.com/makevoid/thorrents.git
    cd thorrents
    bundle install
    RACK_ENV=production rackup

the default rack server starts at http://localhost:9292

open `models/thorz.rb` and fill the HOST constant (you can uncomment one of the lines above)

If you are in Italy or in another place of the world where you can't access to tpb use:

    rackup

to boot it in development mode, that uses thorrents.com JSON api to proxy the results.

enjoy!


### Features

- results ordered by seeds
- magnet links
- fb share


### Credits

- Francesco 'makevoid' Canessa - [makevoid.com](http://makevoid.com)
- Jacopo Santoni - [jacoposantoni.com](http://jacoposantoni.com) for the concept
- Nimrod S.Kerret - [@thedod](https://github.com/thedod) helped with docs and example
- Daniel Olsen - [weremole.deviantart.com](http://weremole.deviantart.com/) for the thor background image
