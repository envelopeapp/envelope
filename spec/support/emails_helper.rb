#
# Helper macro to easily build email messages and "mock" the way a message would be
# returned from Net::IMAP.
#
# @author Seth Vargo
#
module EmailsHelper
  def build_message(filename, *flags)
    struct = OpenStruct.new(
      attr: {
        'RFC822' => File.read("spec/support/emails/#{filename}.eml"),
        'FLAGS' => flags,
        'UID' => rand(1000)
      }
    )

    Envelope::Message.new(struct)
  end
end
