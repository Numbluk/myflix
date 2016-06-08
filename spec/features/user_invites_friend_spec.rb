require 'spec_helper'

feature 'User invites friend' do
  scenario 'where user successfully invites a friend' do
    dave = Fabricate(:user)
    sign_in(dave)
    click_link 'Invite a Friend'

    send_invitation

    invited_friend_clicks_link_in_email_to_register

    invited_friend_registers

    hal = User.find_by(email: 'hal@hal.com')
    expect(hal).to be_present

    invited_friend_signs_in(hal)

    invited_friend_checks_if_following_inviter(dave)
  end

  def send_invitation
    fill_in "Friend's Email", with: 'hal@hal.com'
    fill_in "Friend's Name", with: 'hal the computer'
    fill_in "Message", with: 'You should come along with me.'
    click_button 'Send Invitation'
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
