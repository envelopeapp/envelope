module Jobs
  class ContactImporter < Struct.new(:user_id, :path)
    def before
      @user = User.find(user_id)
    end

    def perform
      begin
        # grab the file
        @file = File.open(path, 'r')

        # load up vcards
        @vcards = Vpim::Vcard.decode(@file)

        # close the file
        @file.close
      rescue Exception => e
        puts "Could not open file: #{e}"
        return
      end

      @vcards.each do |vcard|
        name = vcard.name
        nickname = vcard.nickname.presence || nil
        prefix = name.prefix.presence || nil
        first_name = name.given.presence || nil
        middle_name = name.additional.presence || nil
        last_name = name.family.presence || nil
        suffix = name.suffix.presence || nil

        title = vcard.title.presence || nil
        birthday = vcard.birthday.presence || nil
        notes = vcard.note.presence || nil

        emails = vcard.emails.collect do |e|
          label = e.location.empty? ? nil : e.location.first.strip.titleize
          email_address = e.to_s.strip.presence || nil

          { label:label || 'Default', email_address:email_address }
        end

        phones = vcard.telephones.collect do |p|
          label = p.location.empty? ? nil : p.location.first.strip.titleize
          phone_number = p.to_s.gsub(/[^0-9]/, '').strip

          { label:label || 'Default', phone_number:phone_number }
        end

        addresses = vcard.addresses.collect do |a|
          label = a.location.empty? ? nil : a.location.first.strip.titleize
          lines = a.street.split(/\r\n/)
          line_1 = lines[0].strip.presence || nil
          line_2 = lines[1..-1].join("\n").strip.presence || nil
          city = a.locality.strip.presence || nil
          state = a.region.strip.presence || nil
          country = a.country.strip.presence || nil
          zip_code = a.postalcode.strip.presence || nil

          { label:label || 'Default', line_1:line_1, line_2:line_2, city:city, state:state, country:country, zip_code:zip_code }
        end

        contact = Contact.new({
          user_id: @user._id,
          prefix: prefix,
          first_name: first_name,
          middle_name: middle_name,
          last_name: last_name,
          suffix: suffix,
          title: title,
          birthday: birthday,
          notes: notes,
          emails_attributes: emails,
          phones_attributes: phones,
          addresses_attributes: addresses
        })

        unless contact.save
          PrivatePub.publish_to @user.queue_name, :action => 'error', :message => "Could not save contact #{contact.name} because #{contact.errors.full_messages.join(', ')}"
        end
      end
    end

    def success
      begin
        File.delete(@file)
      rescue Exception => e
        puts "Could not delete file because #{e}"
      end

      PrivatePub.publish_to @user.queue_name, :action => 'info', :message => 'Contacts have finished imported'
    end
  end
end
