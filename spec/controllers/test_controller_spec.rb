require 'rails_helper'

RSpec.describe TestController, type: :controller do
  describe 'access control' do
    it 'allow public access to test#public' do
      get :public
      expect(response).to be_success
    end

    it 'allow admin access to test#admin_only' do
      get :admin_only, roles: 'admin'
      expect(response).to be_success
    end

    it 'allow admin access to test#public' do
      get :public, roles: 'admin'
      expect(response).to be_success
    end

    it 'deny public access to test#admin_only' do
      get :admin_only
      expect(response).to have_http_status(401)
    end

    it 'deny admin access to test#no_access' do
      get :no_access
      expect(response).to have_http_status(401)
    end
  end

  describe 'error tolerance' do
    it 'deny strangers to access test#public' do
      get :public, roles: 'stranger'
      expect(response).to have_http_status(401)
    end

    it 'allow multiple roles to access test#admin_only' do
      get :admin_only, roles: 'admin,user'
      expect(response).to be_success
    end

    it 'allow multiple roles (in whatever order) to access test#admin_only' do
      get :admin_only, roles: 'user,admin'
      expect(response).to be_success
    end

    it 'allow multiple roles (w/ strangers) to access test#public ' do
      get :public, roles: 'user,stranger'
      expect(response).to be_success
    end
  end
end
