+++
date = "2019-05-11T00:59:24-06:00"
title = "Rails 5 I18n Enum Display Helper"
description = "A simple helper to assist with translating enum names for your rails view"
categories = "Software"
tags = ["Ruby", "Rails", "I18n"]
+++

Following the guide over at [Rubyonrails.org](https://guides.rubyonrails.org/i18n.html#translations-for-active-record-models), we can use `human_attribute_name` to help us translate our enum names for the view/display.

Suppose you have a `Member` model like this one:
```rb
class Member < ApplicationRecord
  enum role: %i[user vip admin]
end
```

Add the following to your `config/locales/en.yml`
```yaml
en:
  activerecord:
    attributes:
      member/role:
        user: User
        vip: Very Important Person
        admin: Administrator
```

And this to your `config/locales/pirate.yml`
```yaml
pirate:
  activerecord:
    attributes:
      member/role:
        user: Crew
        vip: First Mate
        admin: Captain
```

Now in our code we can use `Member.human_attribute_name('role.vip')` to obtain `First Mate` when using the pirate locale.

You can create this `EnumDisplayHelper` to clean this up just a little more:


```rb
module EnumDisplayHelper
  # enum_display(Member, :role)
  # enum_display(Member, :role, :vip)
  # enum_display(Member.find(1), :role)
  # Returns the translated enum_attr for a particular class and value
  def enum_display(klass, enum_attr, value = nil)
    if (!klass.is_a? Class)
      value = klass.send(enum_attr)
      klass = klass.class
    end
    klass.human_attribute_name([enum_attr, value].join('.'))
  end

  # enum_options_for_select(Member, :role)
  # Returns an array of enum translations and their raw versions for use
  # in select_tag
  def enum_options_for_select(klass, enum)
    klass.send(enum.to_s.pluralize).map do |key, _|
      [enum_display(klass, enum, key), key]
    end
  end
end
```