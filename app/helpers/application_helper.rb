module ApplicationHelper
  def select_tags_for_ratings(queue_item, form_name = nil)
    select_tag("queue_ids_with_ratings[#{queue_item.id}]",
      options_for_select([
        ['5 Stars', 5],
        ['4 Stars', 4],
        ['3 Stars', 3],
        ['2 Stars', 2],
        ['1 Star', 1]
      ],
      queue_item.user.reviews.find_by(video: queue_item.video).try(:rating)
      ), form: form_name)
  end
end
