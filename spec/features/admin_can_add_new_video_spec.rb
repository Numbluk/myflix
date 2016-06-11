require 'spec_helper'

feature 'Admin can add new video spec' do
  scenario 'admin adds a new video' do
    admin = Fabricate(:admin)
    sleuthing = Fabricate(:category, name: 'Sleuthing')
    sign_in(admin)
    visit new_admin_video_path

    fill_in 'Title', with: 'Monk'
    select 'Sleuthing', from: 'Category'
    fill_in 'Description', with: 'Great show!'
    attach_file 'Large cover', 'spec/support/uploads/monk_large.jpg'
    attach_file 'Small cover', 'spec/support/uploads/monk.jpg'
    fill_in 'Video url', with: 'http://www.example.com/my_video.mp4'
    click_button 'Add Video'

    click_link 'Sign Out'
    sign_in

    visit video_path(Video.first)
    expect(page).to have_selector("img[src='/tmp/monk_large.jpg']")
    expect(page).to have_selector("a[href='http://www.example.com/my_video.mp4']")
  end
end
