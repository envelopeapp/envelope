Envelope
========

[![Build Status](https://secure.travis-ci.org/envelopeapp/envelope.png?branch=master)](http://travis-ci.org/envelopeapp/envelope)

Envelope is a 67-373 project by Dom Cerminara, Elizabeth Li, Seth Vargo, and Xun Wang.

## Pre-Installation
1. Install [elasticsearch](http://www.elasticsearch.org/):

    brew install elasticsearch

2. Run the bundle command:

    bundle install


## Installation
We moved the [installation docs](envelope/wiki/Installation) to the wiki so they don't bog down the README.

## Seeding
You can seed the database like this:

    $ ANDREW_ID=[YOUR ANDREW ID] ANDREW_PASSWORD=[YOUR ANDREW PASSWOrd] bundle exec rake db:seed

This will set up a user:

  - Username: (your andrew id)
  - Password: test

## Structure
Envelope has 4 major components:
  - Web Server ([thin](https://github.com/macournoyer/thin))
  - Websocket Server ([private_pub](https://github.com/ryanb/private_pub))
  - Search Engine ([sunspot](https://github.com/outoftime/sunspot))
  - Background Processing ([delayed_job](https://github.com/collectiveidea/delayed_job))

For more information, such as Installation or Scaling, please see the [Wiki](envelope/wiki/Home).
