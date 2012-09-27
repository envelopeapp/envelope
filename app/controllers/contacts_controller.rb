class ContactsController < ApplicationController
  load_and_authorize_resource :contact, :through => :current_user

  def new
    @contact.emails.build
    @contact.phones.build
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json:@contact.to_json(:include => [:emails, :phones, :addresses]) }
    end
  end

  def search
    @contacts = current_user.contacts.search(params[:term])

    respond_to do |format|
      format.json { render json:@contacts.collect{|c| {:id => c._id, :label => c.name_email, :value => c.email_address}} }
    end
  end

  def create
    if @contact.save
      redirect_to contacts_path, notice: 'Contact was successfully created.'
    else
      render action:'new'
    end
  end

  def import
    @contact = Contact.new

    if params[:contact].present? && params[:contact][:vcards].present?
      Contact.import_from_vcard(current_user, params[:contact][:vcards])
    end
  end

  def update
    if @contact.update_attributes(params[:contact])
      redirect_to contacts_path, notice: 'Contact was successfully updated.'
    else
      render action:'edit'
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_url
  end
end
