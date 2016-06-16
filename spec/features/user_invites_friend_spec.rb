require 'spec_helper'

feature 'User invites friend' do
  scenario 'where user successfully invites a friend', { js: true, vcr: true } do
    dave = Fabricate(:user)
    sign_in(dave)

    send_invitation(dave)

    invited_friend_clicks_link_in_email_to_register

    invited_friend_registers

    wait = Selenium::WebDriver::Wait.new(timeout: 5)
    hal = nil
    wait.until { hal = User.find_by(email: 'hal@hal.com') }
    expect(hal).to be_present

    invited_friend_signs_in(hal)

    invited_friend_checks_if_following_inviter(dave)
  end

  def send_invitation(sender)
    visit invite_path
    fill_in "Friend's Email", with: 'hal@hal.com'
    fill_in "Friend's Name", with: 'hal the computer'
    fill_in "Message", with: 'You should come along with me.'
    click_button 'Send Invitation'
    click_link "Welcome, #{sender.full_name}"
    click_link 'Sign Out'
  end

  def invited_friend_clicks_link_in_email_to_register
    open_email('hal@hal.com')
    current_email.click_link 'Sign up now!'
  end

  def invited_friend_registers
    expect(page).to have_content 'Register'
    fill_in 'Password', with: 'password'
    fill_in 'Full Name', with: 'hal the computer'
    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'Security Code', with: '123'
    select '6 - June', from: 'date_month'
    select '2018', from: 'date_year'
    click_button 'Sign Up'
  end

  def invited_friend_signs_in(friend)
    expect(page).to have_content 'Sign in'
    fill_in 'Email Address', with: friend.email
    fill_in 'Password', with: 'password'
    click_button 'Sign In'
  end

  def invited_friend_checks_if_following_inviter(inviter)
    click_link 'People'
    expect(page).to have_content inviter.full_name
  end
end
