# require 'spec_helper'
#
# feature 'User interacts with queue' do
#   scenario 'user adds and reorders videos in queue' do
#     drama = Fabricate(:category)
#     south_park = Fabricate(:video, id: 1, title: 'South Park', category: drama)
#     warcraft = Fabricate(:video, id: 2, title: 'Warcraft', category: drama)
#     fargo = Fabricate(:video, id: 3, title: 'Fargo', category: drama)
#
#     sign_in
#
#     find("a[href='/videos/#{warcraft.id}']").click
#     expect(page).to have_content(warcraft.title)
#     click_link('+ My Queue')
#     expect(page).to have_content(warcraft.title)
#
#     find("a[href='/videos/#{warcraft.id}']").click
#     expect(page).not_to have_content('+ My Queue')
#
#     visit('/home')
#     find("a[href='/videos/#{south_park.id}']").click
#     click_link('+ My Queue')
#
#     visit('/home')
#     find("a[href='/videos/#{fargo.id}']").click
#     click_link('+ My Queue')
#     binding.pry
#     within(:xpath, "//tr[contains(.,'#{warcraft.title}')]") do
#       fill_in "queue_ids_with_positions[#{warcraft.id}][]", with: 3
#     end
#     within(:xpath, "//tr[contains(.,'#{south_park.title}')]") do
#       fill_in 'queue_ids_with_positions[][position]', with: 2
#     end
#     within(:xpath, "//tr[contains(.,'#{fargo.title}')]") do
#       fill_in 'queue_ids_with_positions[][position]', with: 1
#     end
#
#     click_button 'Update Instant Queue'
#
#     # :xpath, "//tr[contains(.,'#{south_park.title}')]//input[@type='text']"
#   end
# end
