Envelope
========
[![Build Status](https://secure.travis-ci.org/envelopeapp/envelope.png?branch=master)](http://travis-ci.org/envelopeapp/envelope)

Envelope is a web-based email management solution built with Ruby on Rails. We are currently in the process of moving to a JS Framework (Spine). Envelope began as a [CMU Information Systems](https://github.com/cmu-is-projects) project by [Dom Cerminara](https://github.com/domcerminara), [Elizabeth Li](https://github.com/etli), [Seth Vargo](https://github.com/sethvargo), and [Xun Wang](https://github.com/xunix).

Quick Start
-----------
### On a Mac
1. Clone the project

    git clone git@github.com:envelopeapp/envelope.git && cd envelope

2. Run `script/mac`:

        ./script/mac

  I highly encourage you to look at the script for you personal sanity. In short, it:

  1. Install homebrew
  2. Install elasticsearch
  3. Install mongodb
  4. Bundle the gems

3. *(optional)* Seed the database

        GMAIL_USERNAME=[YOUR GMAIL USERNAME] GMAIL_PASSWORD=[YOUR GMAIL PASSWORD] bundle exec rake db:seed

4. Fire up the application

        bundle exec foreman start

### With Vagrant
Envelope is packaged with vagrant and is available for download. It is currently an ubuntu precise64 box packaged with all the necessary dependencies already installed.

1. Install [vagrant](http://vagrantup.com)
2. Clone the project

        git clone git@github.com:envelopeapp/envelope.git && cd envelope

3. Install the envelope base box:

        vagrant box add envelope http://github.com/downloads/envelopeapp/envelope/base.box

4. Initialize the box:

        vagrant init envelope

5. Boot up the VM

        vagrant up

6. You should now be able to ssh into the Ubuntu box:

        vagrant ssh

7. Change into the `/vagrant` bootstrap the application

        ./script/ubuntu

8. *(optional)* Seed the database

        GMAIL_USERNAME=[YOUR GMAIL USERNAME] GMAIL_PASSWORD=[YOUR GMAIL PASSWORD] bundle exec rake db:seed

9. Fire up the application

        bundle exec foreman start

**Note** It is highly recommended that you adjust the VirutalBox settings and give the box at least 2GB of RAM!

## Structure
Envelope has 4 major components:
  - Web Server ([puma](https://github.com/puma/puma))
  - Notifications ([pusher](http://pusher.com/))
  - Search Engine ([elasticsearch](http://www.elasticsearch.org/))
  - Background Processing ([sidekiq](https://github.com/mperham/sidekiq))

For more information, such as Installation or Scaling, please see the [Wiki](envelope/wiki/Home).
