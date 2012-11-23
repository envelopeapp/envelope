# encoding: utf-8

require 'spec_helper'
include EmailsHelper

describe Envelope::Message do
  context 'usual business' do
    subject { build_message 'utf8' }

    its(:uid) { should be_a Fixnum }
    its(:message_id) { should == '0000013a3dd13d53-e53df64e-843c-4dc8-8ee0-63e931f545c3-000000@email.amazonses.com' }
    its(:headers) { should be_a Array }
    its(:mime_type) { should == 'text/html' }
    its(:received) { should be_a Array }
    its(:references) { should be_a Array }
    its(:charset) { should == 'UTF-8' }
    its(:flags) { should be_empty }
    its(:read?) { should be_false }
    its(:deleted?) { should be_false }
    its(:flagged?) { should be_false }
    its(:bounced?) { should be_false }
    its(:multipart?) { should be_false }
    its(:timestamp) { should be_a Time }
    its(:timestamp) { should == '2012-10-08 00:40:53 UTC' }
    its(:subject) { should == 'Andrew Willig paid you $5.00 for Papa John\'s Pizza' }
    its(:to) { should == [OpenStruct.new(name: nil, email_address: 'sethvargo@gmail.com')] }
    its(:from) { should == [OpenStruct.new(name: nil, email_address: 'venmo@venmo.com')] }
    its(:sender) { should be_empty }
    its(:cc) { should be_empty }
    its(:bcc) { should be_empty }
    its(:reply_to) { should == [OpenStruct.new(name: nil, email_address: 'andrew.willig@gmail.com')] }
    its(:attachments?) { should be_false }
    its(:attachments) { should be_empty }
    its(:raw_source) { should be_a String }
    its(:to_s) { should == '#<Envelope::Message to=["sethvargo@gmail.com"] from=["venmo@venmo.com"] cc=[] bcc=[] reply_to=["andrew.willig@gmail.com"] subject="Andrew Willig paid you $5.00 for Papa John\'s Pizza" text_part="Andrew Willig paid you $5.00 for Papa John\'s Pizza ...">' }
    its(:to_yaml) { should match '--- !ruby/object:Envelope::Message' }

    context 'with flags' do
      subject { build_message 'utf8', :read, :flagged, :deleted }

      its(:flags) { should == ['read', 'flagged', 'deleted'] }
      its(:read?) { should be_true }
      its(:deleted?) { should be_true }
      its(:flagged?) { should be_true }
    end
  end

  context 'appended_messages_1' do
    subject { build_message 'appended_messages_1' }

    its(:text_part) { should_not match /On Wed, Oct 3, 2012 at 1:13 PM/ }
    its(:text_part) { should match /^Does this help\?/ }
    its(:html_part) { should_not match /On Wed, Oct 3, 2012 at 1:13 PM/ }
  end

  context 'appended_messages_2' do
    subject { build_message 'appended_messages_2' }

    its(:text_part) { should_not match /Begin forwarded message:/ }
    its(:text_part) { should match /^i can't find the folder anymore/ }
    its(:html_part) { should_not match /Begin forwarded message:/ }
  end

  context 'appended_messages_3' do
    subject { build_message 'appended_messages_3' }

    its(:text_part) { should_not match /From:\s+Seth Vargo/ }
    its(:text_part) { should match /^Seth,\nwe received the photo copies of/ }
    its(:html_part) { should_not match /<b>From:<\/b> Seth Vargo/ }
  end

  context 'base64 encoded' do
    subject { build_message 'base64' }

    its(:text_part) { should == <<-EOH.strip
=== Web - 1 new result for ["Seth Vargo"] ===

Custom Global Eco/JST helpers ? It's My Life - Seth Vargo's Blog
Custom Global Eco/JST helpers Working on Envelope lately, I realized the
need for custom form helpers. We use Twitter Bootstrap for the form styles
and layout, ...
<http://www.google.com/url?sa=X&q=http://sethvargo.com/post/32742807598/custom-global-eco-jst-helpers&ct=ga&cad=CAcQARgAIAEoATAAOABAm4W4gwVIAVgAYgVlbi1VUw&cd=ebkNIvPatV8&usg=AFQjCNH9hfBTkEeBFG8TSR-fM0ZfXcUDsA>

This as-it-happens Google Alert is brought to you by Google.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Delete this Google Alert:
http://www.google.com/alerts/remove?hl=en&gl=us&source=alertsmail&s=AB2Xq4jGLzgsan55HmFoGBjM_ZPeerN1YcRYpYY&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE

Create another Google Alert:
http://www.google.com/alerts?hl=en&gl=us&source=alertsmail&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE

Sign in to manage your alerts:
http://www.google.com/alerts/manage?hl=en&gl=us&source=alertsmail&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE
EOH
}
    its(:html_part) { should == "<html><head></head><body><div style=\"font-family: arial,sans-serif; width: 600px\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"600px\"><tr><td style=\"background-color:#EBEFF9; padding: 4px 8px 4px 8px\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\"><tr><td><font size=\"-1\"><nobr><b>Web</b></nobr></font></td><td width=\"70%\" align=\"right\"><font size=\"-1\"><b>1</b> new result for <b>&quot;Seth Vargo&quot;</b></font></td></tr></table></td></tr><tr><td> </td></tr><tr><td style=\"padding: 0px 8px 16px 8px;\"><a style=\"color: #1111CC\" href=\"http://www.google.com/url?sa=X&amp;q=http://sethvargo.com/post/32742807598/custom-global-eco-jst-helpers&amp;ct=ga&amp;cad=CAcQARgAIAEoATAAOABAm4W4gwVIAVgAYgVlbi1VUw&amp;cd=ebkNIvPatV8&amp;usg=AFQjCNH9hfBTkEeBFG8TSR-fM0ZfXcUDsA\">Custom Global Eco/JST helpers ? It&#39;s My Life - <b>Seth Vargo&#39;s</b> Blog</a><br><font size=\"-1\">Custom Global Eco/JST helpers Working on Envelope lately, I realized the need for custom form helpers. We use Twitter Bootstrap for the form styles and layout, <b>...</b><br><a style=\"color:#228822\" href=\"http://www.google.com/url?sa=X&amp;q=http://sethvargo.com/post/32742807598/custom-global-eco-jst-helpers&amp;ct=ga&amp;cad=CAcQARgAIAEoBDAAOABAm4W4gwVIAVgAYgVlbi1VUw&amp;cd=ebkNIvPatV8&amp;usg=AFQjCNH9hfBTkEeBFG8TSR-fM0ZfXcUDsA\" title=\"http://sethvargo.com/post/32742807598/custom-global-eco-jst-helpers\">sethvargo.com/post/.../custom-global-eco-jst-helpers</a></font></td></tr></table><br><hr noshade size=\"1\" color=\"#CCCCCC\"><font size=\"-1\">Tip: Use site restrict in your query to search within a site (site:nytimes.com or site:.edu). <a href='http://www.google.com/support/websearch/bin/answer.py?answer=136861&hl=en&source=alertsmail&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE'>Learn more</a>.</font><br><br><font size=\"-1\"><a href=\"http://www.google.com/alerts/remove?hl=en&gl=us&source=alertsmail&s=AB2Xq4jGLzgsan55HmFoGBjM_ZPeerN1YcRYpYY&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE\">Delete</a> this alert.<br><a href=\"http://www.google.com/alerts?hl=en&gl=us&source=alertsmail&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE\">Create</a> another alert.<br><a href=\"http://www.google.com/alerts/manage?hl=en&gl=us&source=alertsmail&cd=ebkNIvPatV8&cad=CAcQARgAQJuFuIMFSAE\">Manage</a> your alerts.</font></div></body></html>" }
  end

  context 'forwarded message' do
    subject { build_message 'forwarded' }

    its(:text_part) { should_not match /---------- Forwarded message ----------/ }
    its(:text_part) { should match /\ASeth,\nHere are the emails I sent on the 13th/ }
    its(:html_part) { should_not match /On Wed, Oct 3, 2012 at 1:13 PM/ }
    its(:html_part) { should_not match /---------- Forwarded message ----------/ }
  end

  context 'google_group_summary' do
    subject { build_message 'google_group_summary' }

    its(:text_part) { should match /\A=+\nToday's Topic Summary\n=+/ }
    its(:html_part) { should_not match /Begin forwarded message:/ }
  end

  context 'html_only' do
    subject { build_message 'html_only' }

    its(:text_part) { should_not be_nil }
    its(:text_part) { should match /\APlease verify your email address to activate your account/ }
    its(:html_part) { should match /\A<p>Please verify your email address to activate your account:<\/p>/ }
  end

  context 'multipart' do
    subject { build_message 'multipart' }

    its(:text_part) { should match /\ABuild Update for envelopeapp\/envelope/ }
    its(:html_part) { should match /envelopeapp\/envelope/ }
    its(:multipart?) { should be_true }
  end

  context 'multipart_alternative' do
    subject { build_message 'multipart_alternative' }

    its(:text_part) { should match /\AWe have begun the database upgrade on your app, plotify./ }
    its(:html_part) { should match /\A<p>We have begun the database upgrade on your app, plotify./ }
    its(:multipart?) { should be_true }
  end

  context 'no_subject' do
    subject { build_message 'no_subject' }

    its(:subject) { should be_nil }
    its(:text_part) { should match /\ADear Default,\nThank you for registering with Envelope!/ }
    its(:html_part) { should match /\A<h1>Dear Default,<\/h1>\n<p>Thank you for registering with Envelope!/ }
  end

  context 'no_html' do
    subject { build_message 'no_html' }

    its(:text_part) { should match /\ADear Customer,\nYour Planio trial period has expired/ }
    its(:html_part) { should match /\ADear Customer,\n\nYour Planio trial period has expired./ }
    its(:sanitized_html) { should match /\A<p>Dear Customer,<br><br>Your Planio trial period has expired/ }
  end

  context 'original_message' do
    subject { build_message 'original_message' }

    its(:text_part) { should_not match /-----Original Message-----/ }
    its(:text_part) { should == "Hi, Seth,\n\nThe final amount is $3,000.00" }
    its(:html_part) { should_not match /-----Original Message-----/ }
    its(:sanitized_html) { should == "<p>Hi, Seth,</p><p></p><p>The final amount is $3,000.00</p>" }
  end

  context 'reply_to' do
    subject { build_message 'reply_to' }

    its(:reply_to) { should == [OpenStruct.new(name:'ryanb/cancan', email_address:'reply+i-6585950-3b8d3e844c77be9762ce3ba57f57201dc4f79aae-408570@reply.github.com')] }
  end

  context 'us_ascii' do
    subject { build_message 'us_ascii' }

    its(:text_part) { should match /\AThis message is the reminder you requested to pay American Honda Finance for account xxxxxxxxx/ }
    its(:html_part) { should match /This message is the reminder you requested to pay American Honda Finance for account xxxxxxxxx/ }
    its(:sanitized_html) { should match /\A<p>This message is the reminder you requested to pay American Honda Finance for account xxxxxxxxx/ }
  end

  context 'utf8' do
    subject { build_message 'utf8' }

    its(:text_part) { should match /\AAndrew Willig\npaid you\n\$5\.00\n\n\n\nfor Papa John\'s Pizza/ }
    its(:html_part) { should match /Andrew Willig/ }
    its(:sanitized_html) { should match /<table.*>/ }
  end
end
