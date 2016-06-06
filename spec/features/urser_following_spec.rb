require 'spec_helper'

feature 'User following' do
  scenario 'following and unfollowing users' do
    drama = Fabricate(:category)
    video = Fabricate(:video, category: drama)

    dave = Fabricate(:user)
    sign_in(dave)
    hal = Fabricate(:user)

    review = Fabricate(:review, user: hal, video: video)

    find("a[href='/videos/#{video.id}']").click
    click_link(hal.full_name)
    click_link('Follow')
    expect(page).to have_content hal.full_name

    unfollow(hal)
    expect(page).not_to have_content hal.full_name
  end

  private

  def unfollow(user)
    find("a[data-method='delete']").click
  end
end
