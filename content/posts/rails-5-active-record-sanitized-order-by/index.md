+++
date = "2018-11-15T11:23:24-07:00"
title = "Rails 5 ActiveRecord Sanitized Order By"
description = "Full sanitation method for rails order method even with joins"
categories = "Software"
tags = ["Ruby", "Rails", "ActiveRecord"]
+++

It may surprise you to find out that the default rails [`order`](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order) function does not sanitize input. This can lead to potentially dangerous sql injections. Additionally, Rails 5 is starting to throw warnings when using `order` or [`sanitize_sql_for_order`](https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_for_order):

```
DEPRECATION WARNING: Dangerous query method (method whose arguments are used as raw SQL) called with non-attribute argument(s): "field(id, ?)". Non-attribute arguments will be disallowed in Rails 6.0. This method should not be called with user-provided values, such as request parameters or model attributes. Known-safe values can be passed by wrapping them in Arel.sql().
```

I don't like users to be able to cause sql errors even with the worst input. I like clean logs. I went looking for someone who has solved this problem but didn't find much. There was a decent [sanitation function](https://gist.github.com/TheKidCoder/9653073) in a gist on github but it doesn't work with joins. Here is a version of that function that operates cleanly when used on a joined query.

```rb
# Refactored from https://gist.github.com/TheKidCoder/9653073
class ActiveRecord::Relation
  def sanitized_order(order_by, direction = 'ASC')
    if order_by.include?('.')
      klass, column = order_by.split('.')
      unless joins_values.include?(klass.pluralize.to_sym)
        raise "#{klass} unavailable in query"
      end
      klass = klass.singularize.classify.constantize
    else
      klass = self.klass
      column = order_by
    end

    raise "Column #{column} not found in #{klass.name}" unless klass.column_names.include?(column.to_s)
    raise 'Invalid direction value' unless %w[ASC DESC].include?(direction.upcase)

    order("#{order_by} #{direction.upcase}")
  end
end
```
