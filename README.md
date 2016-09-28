# CantCantCant

[![Build Status](https://travis-ci.org/shouya/cant_cant_cant.svg?branch=master)](https://travis-ci.org/shouya/cant_cant_cant)

I want an authentication to:

- be light weight and simple, working in a controllable way;
- be role based, where roles and users are multiple-to-multiple relation;
- apply on controller actions;
- have access control in a single configuration file;
- be able to export a list of permissions for roles

So CanCan[Can] just can't satisfy my requirement. And then CantCantCant is the wheel invented for above purposes.

## Installation

Add the following line to your `Gemfile` and execute `bundle`.

    gem 'cant_cant_cant'

Then run:

    $ rails generate cant_cant_cant:install

to generate the config and the initializer.

To get authentication works, you have to adjust `config/cant_cant_cant.yml` for your own need.

After all you need to tell CantCantCant how to acquire your current role(s). Modify the code in `config/initializers/cant_cant_cant.rb`.

CantCantCant will raise an exception on unauthorized access. In order to handle the error yourself, take a look on the related code in `config/initializers/cant_cant_cant.rb`.

## Usage

You're done. There is no need to configure more in any of your controllers.

Note that live reloading is not supported yet; it means you'll need to restart your server after modifying your actions/controllers/config to take effect.

If you need to acquire a list of actions that given roles have access to, just call `CantCantCant.permissions_for(roles)`.


## Configuration

The configuration is located in `config/cant_cant_cant.yml`. The path to configuration file can be modified in the initializer.

The configuration is a YAML document that looks like:

```yaml
user: &default_permissions
  test#public: allow
  test#admin_only: deny
  test#no_access: deny

admin:
  <<: *default_permissions
  test#admin_only: allow
```

## Initializer

You can adjust the initializer as you want, the only thing to notice is that you need to call `CantCantCant.initialize` before making any request, otherwise the authentication won't take effect.

CantCantCant need a `current_roles` method, you should implement it by your own according to the template, either in the initializer or in your own `ApplicationController`. You can also handle the `PermissionDenied` exception in the same way.

Using `rails generate cant_cant_cant:install`, the template will be generated for you in the initializer.

```ruby
class ActionController::Base
  # Write your own handler
  rescue_from CantCantCant::PermissionDenied do
    render plain: 'permission denied', status: 403
  end

  # Write your own method to return the roles for current user
  def current_roles
    return [] unless defined? current_user
    return [] if current_user.empty?

    current_user.roles
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
