require 'vcard'

#
# Import contacts from vcards
#
# @author Seth Vargo
#
class VcardWorker
  include Sidekiq::Worker

  def perform(user_id, path)
    @user = User.find(user_id)
    @file = File.open(path, 'r')
    @vcards = Vpim::Vcard.decode(@file)
    @file.close
    @contacts = []

    @vcards.each do |vcard|
      @contacts << Contact.create({
        user_id: @user.id,
        prefix: vcard.name.prefix.presence,
        first_name: vcard.name.given.presence,
        middle_name: vcard.name.additional.presence,
        last_name: vcard.name.family.presence,
        suffix: vcard.name.suffix.presence,
        title: vcard.title.presence,
        birthday: vcard.birthday.presence,
        notes: vcard.note.presence,
        emails_attributes: emails_for(vcard),
        phones_attributes: phones_for(vcard),
        addresses_attributes: addresses_for(vcard)
      })
    end

    publish_finish
  end

  private
  def emails_for(vcard)
    vcard.emails.collect do |e|
      label = e.location.empty? ? nil : e.location.first.strip.titleize
      email_address = e.to_s.strip.presence

      { label: label || 'Default', email_address: email_address }
    end
  end

  def phones_for(vcard)
    vcard.telephones.collect do |p|
      label = p.location.empty? ? nil : p.location.first.strip.titleize
      phone_number = p.to_s.gsub(/[^0-9]/, '').strip

      { label: label || 'Default', phone_number: phone_number }
    end
  end

  def addresses_for(vcard)
    vcard.addresses.collect do |a|
      label = a.location.empty? ? nil : a.location.first.strip.titleize
      lines = a.street.split(/\r\n/)
      line_1 = lines[0].strip.presence
      line_2 = lines[1..-1].join("\n").strip.presence
      city = a.locality.strip.presence
      state = a.region.strip.presence
      country = a.country.strip.presence
      zip_code = a.postalcode.strip.presence

      { label: label || 'Default', line_1: line_1, line_2: line_2, city: city, state: state, country: country, zip_code: zip_code }
    end
  end

  def publish_finish
    #@user.publish('vcard-worker-finish', { contacts: @contacts })
  end
end
