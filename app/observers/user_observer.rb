class UserObserver < ActiveRecord::Observer
  def after_create(user)
    create_default_labels(user)
    create_default_contact(user)
  end

  private
  def create_default_labels(user)
    user.labels.create!(name:'Home', color:'label-warning')
    user.labels.create!(name:'Todo', color:'label-info')
  end

  def create_default_contact(user)
    user.contacts.create!(
      first_name: 'Envelope',
      last_name: 'Test',
      emails_attributes: [
        { label:'Default', email_address:'teamenvelope@gmail.com' }
      ]
    )
  end
end
