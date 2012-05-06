# This file loads up the encryption key and stores it in a constant that is
# accessible to the entire application. This is so we can encrypt and securely
# store IMAP logins in the database.
Envelope::Application.config.encryption_key = '534ba61462ad0c1d2cfd0477ef91417f5fc68fe30c35e86b1314f8002ee52826d54b20a1d2f9797835483aab38e0cb76e6948e809e07b386a7879c6c14e712fd'