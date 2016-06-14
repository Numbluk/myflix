require 'spec_helper'

feature 'User registers with info and cc spec', { js: true, vcr: true } do
  feature 'with valid cc information' do
    background do
      visit register_path
      cc_number = '4242424242424242'
      fill_out_cc_information(cc_number)
    end

    scenario 'with valid personal information the account is created' do
      dave = Fabricate.attributes_for(:user)
      fill_out_personal_information(dave)
      click_button 'Sign Up'
      expect(page).to have_content 'Account successfully created.'
    end

    scenario 'with invalid personal information the account is not created' do
      dave = Fabricate.attributes_for(:user, email: '')
      fill_out_personal_information(dave)
      click_button 'Sign Up'
      expect(page).to have_content 'Register'
    end
  end

  feature 'with valid personal information' do
    before do
      visit register_path
      dave = Fabricate.attributes_for(:user)
      fill_out_personal_information(dave)
    end

    scenario 'with valid cc information the account is created' do
      cc_number = '4242424242424242'
      fill_out_cc_information(cc_number)
      click_button 'Sign Up'
      expect(page).to have_content 'Account successfully created'
    end

    scenario 'with invalid cc number the account is not created' do
      cc_number = '4000000000000069'
      fill_out_cc_information(cc_number)
      click_button 'Sign Up'
      expect(page).to have_content 'expired'
    end

    scenario 'with declined card the account is not created' do
      cc_number = '4000000000000002'
      fill_out_cc_information(cc_number)
      click_button 'Sign Up'
      expect(page).to have_content 'declined'
    end
  end
end

def fill_out_personal_information(user)
  fill_in 'Email Address', with: user[:email]
  fill_in 'Password', with: user[:password]
  fill_in 'Full Name', with: user[:full_name]
end

def fill_out_cc_information(cc_number)
  fill_in 'Credit Card Number', with: cc_number
  fill_in 'Security Code', with: '123'
  select '6 - June', from: 'date_month'
  select '2018', from: 'date_year'
end
