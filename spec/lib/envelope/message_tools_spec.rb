# encoding: utf-8
require 'spec_helper'

describe Envelope::MessageTools do
  let(:tools) { Envelope::MessageTools }

  context '.sanitize' do
    %w(style class id font-size color size face bgcolor).each do |attribute|
      it "removes '#{attribute}' attributes" do
        text = "<p #{attribute}=\"foo\">Hello</p>"
        tools.sanitize(text).should == '<p>Hello</p>'
      end
    end

    %w(script link img style).each do |tag|
      it "removes <#{tag}> tags" do
        text = "<#{tag} foo=\"bar\"></#{tag}>"
        tools.sanitize(text).should == ''
      end
    end

    it 'removes comments' do
      text = '<!-- Header here --><p><!-- What? -->Hello</p><!-- Footer -->'
      tools.sanitize(text).should == '<p>Hello</p>'
    end

    it 'converts all <div>s to <p>s' do
      text = '<div>Hello</div>'
      tools.sanitize(text).should == '<p>Hello</p>'
    end

    it 'removes font and span tags and preserves content' do
      text = '<font>This is a <span>span</span> inside a <font>font!</font></font>'
      tools.sanitize(text).should == '<p>This is a span inside a font!</p>'
    end

    it 'wraps orphans in <p> tags' do
      text = 'Sad panda :('
      tools.sanitize(text).should == '<p>Sad panda :(</p>'
    end

    it 'removes <p><br></p>' do
      text = '<p>This is<p><br></p>strange</p>'
      tools.sanitize(text).should == '<p>This is</p><p></p><p>strange</p>'
    end

    it 'converts new lines to <br>s' do
      text = <<-EOH.strip
<p>
  This is a multiline message
  that should have <br> tags
  when read later.
</p>
EOH
      tools.sanitize(text).should == '<p><br>  This is a multiline message<br>  that should have  tags<br>  when read later.<br></p>'
    end
  end

  context '.html_to_text' do
    it 'removes <script> tags' do
      text = "<script src=\"http://www.google.com\">alert('hello');</script>Hello, what's up?"
      tools.html_to_text(text).should == "Hello, what's up?"
    end

    it 'removes <link> tags' do
      text = "<link rel=\"stylesheet\" src=\"google.com\" />Hello, what's up?"
      tools.html_to_text(text).should == "Hello, what's up?"
    end

    it 'removes <img> tags' do
      text = "<img src=\"http://www.google.com\" />Hello, what's up?"
      tools.html_to_text(text).should == "Hello, what's up?"
    end

    it 'converts <br> to \n' do
      text = <<-EOH.strip
<div style=3D"DIRECTION: ltr" id=3D"divRpF359961">
<hr tabindex=3D"-1">
<font color=3D"#000000" size=3D"2" face=3D"Tahoma">
<b>From:</b> Seth Vargo [seth.vargo@gmail.com] On Behalf Of Seth Vargo [sethvargo@gmail.com]<br>
<b>Sent:</b> Thursday, October 11, 2012 4:08 PM<br>
<b>To:</b> Dani McDonough<br>
<b>Subject:</b> Re:<br>
</font><br>
</div>
EOH
      tools.html_to_text(text).should == <<-EOH.strip
From: Seth Vargo [seth.vargo@gmail.com] On Behalf Of Seth Vargo [sethvargo@gmail.com]
Sent: Thursday, October 11, 2012 4:08 PM
To: Dani McDonough
Subject: Re:
EOH
    end

    it 'converts <br> to a newline' do
      text = "This should be<br>on two lines!"
      tools.html_to_text(text).should == "This should be\non two lines!"
    end

    it 'foo' do
      text = <<-EOH.strip
<body ocsi=3D"x">
  <div style=3D"FONT-FAMILY: Tahoma; DIRECTION: ltr; COLOR: #000000; FONT-SIZE: x-small">
    <div>Seth,</div>
    <div>We received the photo copies of the card and drivers license but not the cover sheet.</div>
    <div>Have a great day!!</div>
    <div>&nbsp;</div>
    <div>
      <div><font face=3D"Bell MT">Danielle McDonough&nbsp;</font></div>
      <div><font face=3D"Bell MT">Operations&nbsp;Supervisor </font></div>
      <div><font face=3D"Bell MT">Hilton Garden Inn University Place</font></div>
      <div><font face=3D"Bell MT">3454 Forbes Ave,&nbsp;Pittsburgh PA 15213&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </font></div>
      <div><font color=3D"#ff00ff" face=3D"bell mt"></font>&nbsp;</div>
      <div>&nbsp;</div>
    </div>
  </div>
</body>
EOH

      tools.html_to_text(text).should == <<-EOH.strip
Seth,
We received the photo copies of the card and drivers license but not the cover sheet.
Have a great day!!

Danielle McDonough
Operations Supervisor
Hilton Garden Inn University Place
3454 Forbes Ave, Pittsburgh PA 15213
EOH
    end

    it 'preserves content in nested tags' do
      text = "<font class\"foo\">This is <span>freak<strong>ing</strong></span> awesome!</font>"
      tools.html_to_text(text).should == 'This is freaking awesome!'
    end

    it 'removes leading whitespace' do
      text = "<body>\n\n\nThis is awesome!</body>"
      tools.html_to_text(text).should == 'This is awesome!'
    end

    it 'removes trailing whitespace' do
      text = "<body>This is awesome!\n\n\n\n</body>"
      tools.html_to_text(text).should == 'This is awesome!'
    end
  end

  context '.remove_appended_messages' do
    it 'removes "On Nov 8, 2012, at 7:52 PM, Robbin Stormer wrote:"' do
      text = <<-EOH
That's awesome!
On Nov 8, 2012, at 7:52 PM, Robbin Stormer wrote:
> Hi Seth....Well do you know how much I love you?
EOH
      tools.remove_appended_messages(text).should == "That's awesome!"
    end

    it 'removes "On Nov 9, 2012, at 4:35 PM, Sam Smith <sam@smith.com> wrote:"' do
      text = <<-EOH
That's awesome!
On Nov 9, 2012, at 4:35 PM, Paul Edelhertz <pedelhertz@opscode.com> wrote:
Cookies and creame and ponies too!
EOH
      tools.remove_appended_messages(text).should == "That's awesome!"
    end

    it 'removes "On Nov 5, 2012, at 11:28 AM, "Lionel \"Ltrain\" Cares" <sigmachi01@gmail.com> wrote:"' do
      text = <<-EOH
That's awesome!
On Nov 5, 2012, at 11:28 AM, "Lionel \"Ltrain\" Cares" <sigmachi01@gmail.com> wrote:
Awesome sauce!
EOH

      tools.remove_appended_messages(text).should == "That's awesome!"
    end

    it 'removes "On Nov 2, 2012, at 3:15 PM, "Bryan McLellan (JIRA)" wrote:"' do
      text = <<-EOH
That's awesome!
On Nov 2, 2012, at 3:15 PM, "Bryan McLellan (JIRA)" wrote:
Chef is awesome!
EOH

      tools.remove_appended_messages(text).should == "That's awesome!"
    end
  end
end
