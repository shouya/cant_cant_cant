class TestController < ApplicationController
  def public
    render plain: 'public'
  end

  def admin_only
    render plain: 'admin_only'
  end

  def no_access
    render plain: 'no_access'
  end
end
