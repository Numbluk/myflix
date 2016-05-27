require 'spec_helper'

feature 'User interacts with queue' do
  scenario 'user adds and reorders videos in queue' do
    drama = Fabricate(:category)
    south_park = Fabricate(:video, id: 1, title: 'South Park', category: drama)
    warcraft = Fabricate(:video, id: 2, title: 'Warcraft', category: drama)
    fargo = Fabricate(:video, id: 3, title: 'Fargo', category: drama)

    sign_in

    add_video_to_queue(warcraft)
    expect(page).to have_content(warcraft.title)

    visit video_path(warcraft)
    expect(page).not_to have_content('+ My Queue')

    add_video_to_queue(south_park)
    add_video_to_queue(fargo)

    fill_in_item_position_in_queue(warcraft, 3)
    fill_in_item_position_in_queue(south_park, 2)
    fill_in_item_position_in_queue(fargo, 1)

    click_button 'Update Instant Queue'

    expect_video_at_position(south_park, '2')
    expect_video_at_position(warcraft, '3')
    expect_video_at_position(fargo, '1')
  end

  def add_video_to_queue(video)
    visit home_path
    find("a[href='/videos/#{video.id}']").click
    click_link('+ My Queue')
  end

  def fill_in_item_position_in_queue(video, position)
    within(:xpath, "//tr[contains(.,'#{video.title}')]") do
      fill_in 'queue_items[][position]', with: position
    end
  end

  def expect_video_at_position(video, position)
    expect(find(:xpath, "//tr[contains(., '#{video.title}')]//input[@type='text']").value).to eq(position)
  end

end
