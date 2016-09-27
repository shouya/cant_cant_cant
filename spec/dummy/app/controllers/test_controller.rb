class TestController < ApplicationController
  def public
    render text: 'public'
  end

  def admin_only
    render text: 'admin_only'
  end

  def no_access
    render text: 'no_access'
  end
end
