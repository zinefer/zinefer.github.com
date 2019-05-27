+++
date = "2019-05-26T21:43:10-06:00"
title = "Testing SandboxEmailInterceptor Initializer in Rails 5"
description = "How to test an environment based initialized in Rails 5 with minitest"
categories = "Software"
tags = ["Ruby", "Rails", "Minitest"]
+++

I recently needed to implement some tests for the `SandboxEmailInterceptor` Intializer pattern suggested by the [rails guide](https://guides.rubyonrails.org/v5.0.0/action_mailer_basics.html#intercepting-emails). I found two methods to test the class but neither of them are perfect.

## You can test the functionality of the interceptor

```rb
test 'it should redirect email when interceptor is run' do
  SandboxEmailInterceptor.delivering_email(@email)
  assert_equal @email.to, ['sandbox@example.com']
end
```

However, passing this test doesn't mean your emails will be intercepted.

## Stub the environment and load the initializer

```rb
test 'it sends all emails to staging@donorsiblingregistry.com in staging' do
  Rails.stub(:env, ActiveSupport::StringInquirer.new('staging')) do
    load 'config/initializers/sandbox_email_interceptor.rb'

    @email.deliver

    last_email_sent = ActionMailer::Base.deliveries.last
    assert_equal last_email_sent.to, ['sandbox@example.com']
  end
end
```

This gets us closer but if your initializers aren't running, for example then this test will still be inadequate. I haven't found a better solution than this one so please comment if you know of one.