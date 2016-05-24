Fabricator(:review) do
  rating { rand(1..5) }
  content { Faker::Lorem.paragraph(3) }
end
