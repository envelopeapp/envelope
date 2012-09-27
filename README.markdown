Envelope
========
[![Build Status](https://secure.travis-ci.org/envelopeapp/envelope.png?branch=master)](http://travis-ci.org/envelopeapp/envelope)

Envelope is a web-based email management solution built with Ruby on Rails. We are currently in the process of moving to a JS Framework (Spine). Envelope began as a [CMU Information Systems](https://github.com/cmu-is-projects) project by [Dom Cerminara](https://github.com/domcerminara), [Elizabeth Li](https://github.com/etli), [Seth Vargo](https://github.com/sethvargo), and [Xun Wang](https://github.com/xunix).

## Quick Start
1. Run `script/setup`:

        ./script/setup

  I highly encourage you to look at the script for you personal sanity. In short, it:

  1. Install homebrew
  2. Install elasticsearch
  3. Install mongodb
  4. Bundle the gems

2. *(optional)* Seed the database

        GMAIL_USERNAME=[YOUR GMAIL USERNAME] GMAIL_PASSWORD=[YOUR GMAIL PASSWORD] bundle exec rake db:seed

## Structure
Envelope has 4 major components:
  - Web Server ([puma](https://github.com/puma/puma))
  - Notifications ([pusher](http://pusher.com/))
  - Search Engine ([elasticsearch](http://www.elasticsearch.org/))
  - Background Processing ([delayed_job](https://github.com/collectiveidea/delayed_job))

For more information, such as Installation or Scaling, please see the [Wiki](envelope/wiki/Home).
