require 'spec_helper'

feature 'User resets password' do
  let(:dave) { Fabricate(:user, password: 'old') }

  scenario 'user can reset password' do
    visit sign_in_path
    click_link 'Forgot Password?'
    fill_in('Email Address', with: dave.email)
    click_button 'Send Email'

    open_email(dave.email)
    current_email.click_link 'Reset My Password'

    fill_in 'New Password', with: 'new'
    click_button 'Reset Password'

    fill_in 'Email Address', with: dave.email
    fill_in 'Password', with: 'new'
    click_button 'Sign In'

    expect(page).to have_content 'You are now logged in!'
  end
end
