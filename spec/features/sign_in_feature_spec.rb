require 'spec_helper'

feature 'Signing In' do
  given(:user) { Fabricate(:user) }

  scenario 'Signing in with correct credentials' do
    sign_in
    expect(page).to have_content 'You are now logged in!'
  end
end
