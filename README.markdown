Envelope
========

[![Build Status](https://secure.travis-ci.org/envelopeapp/envelope.png?branch=master)](http://travis-ci.org/envelopeapp/envelope)

Envelope is a 67-373 project by Dom Cerminara, Elizabeth Li, Seth Vargo, and Xun Wang.


## Installation
We moved the [installation docs](envelope/wiki/Installation) to the wiki so they don't bog down the README.

```bash
export GMAIL_USERNAME=[username]
export GMAIL_PASSWORD=[password]
bundle exec rake db:setup
```

## Structure
Envelope has 4 major components:
  - Web Server ([thin](https://github.com/macournoyer/thin))
  - Websocket Server ([private_pub](https://github.com/ryanb/private_pub))
  - Search Engine ([sunspot](https://github.com/outoftime/sunspot))
  - Background Processing ([delayed_job](https://github.com/collectiveidea/delayed_job))

For more information, such as Installation or Scaling, please see the [Wiki](envelope/wiki/Home).
