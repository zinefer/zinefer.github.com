+++
date = "2018-10-06T10:19:08-06:00"
title = "Gradual engagement with Rails 5 & Devise 4"
description = "How to create an email only registration flow for rails and devise"
categories = "Software"
tags = ["Ruby", "Rails", "Devise", "Gradual Engagement"]
+++

This is going to be a quick overview on how to alter devise to allow for email only registration flow. You should be able to adapt this process to accomodate most gradual engagement setups.

Here are the basic steps:

- [Overload password verification methods in the user model](#overload-password-verification-methods-in-the-user-model)
- [Remove password fields from registration template](#remove-password-fields-from-registration-template)
- [Extend confirmations controller to allow a two step confirmation](#extend-confirmations-controller-to-allow-a-two-step-confirmation)

# Overload password verification methods in the user model

Add these methods to your user model.

```rb
def password_required?
  super if confirmed?
end

def password_match?
  self.errors[:password] << "can't be blank" if password.blank?
  self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
  self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
  password == password_confirmation && !password.blank?
end
```

# Remove password fields from registration template

Remove the password fields from `app/views/devise/registrations/new.html.erb`, here is what mine looked like:

```html+erb
<div class="field">
  <%= f.label :password %>
  <% if @minimum_password_length %>
  <em>(<%= @minimum_password_length %> characters minimum)</em>
  <% end %><br />
  <%= f.password_field :password, autocomplete: "new-password" %>
</div>
 <div class="field">
  <%= f.label :password_confirmation %><br />
  <%= f.password_field :password_confirmation, autocomplete: "new-password" %>
</div>
```

# Extend confirmations controller to allow a two step confirmation

Create `dsr/app/controllers/confirmations_controller.rb`:
```rb
class ConfirmationsController < Devise::ConfirmationsController
  def show
    if params[:confirmation_token].present?
      @original_token = params[:confirmation_token]
    elsif params[resource_name].try(:[], :confirmation_token).present?
      @original_token = params[resource_name][:confirmation_token]
    end

    self.resource = resource_class.find_by_confirmation_token @original_token
  end

  def confirm
    @original_token = params[resource_name].try(:[], :confirmation_token)

    self.resource = resource_class.find_by_confirmation_token! @original_token
    resource.assign_attributes(permitted_params) unless params[resource_name].nil?

    if resource.valid? && resource.password_match?
      self.resource.confirm
      set_flash_message :notice, :confirmed
      sign_in_and_redirect resource_name, resource
    else
      render :action => 'show'
    end
  end

 private
   def permitted_params
     params.require(resource_name).permit(:confirmation_token, :password, :password_confirmation)
   end
end
```

Create `dsr/app/views/devise/confirmations/show.html.erb`:
```html+erb
<h2>You're almost done! Now create a password to securely access your account.</h2>
<%= form_for(resource, as: resource_name, url: confirm_path, html: { method: :patch }) do |f| %>
  <%= devise_error_messages! %>

  <div class="field">
    <%= f.label :password %><br />
    <%= f.password_field :password, autofocus: true %>
  </div>

  <div class="field">
    <%= f.label :password_confirmation %><br />
    <%= f.password_field :password_confirmation, autofocus: true %>
  </div>

  <%= f.hidden_field :confirmation_token, :value => @original_token %>

  <div class="actions">
    <%= f.submit "Sign up" %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

Alter the devise routes to use our new extended controller:
```rb
devise_for :users, :controllers => {:confirmations => 'confirmations'}
devise_scope :user do
  patch "/confirm" => "confirmations#confirm"
end
```
