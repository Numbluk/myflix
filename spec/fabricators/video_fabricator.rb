Fabricator(:video) do
  title { Faker::Lorem.words(5).join(' ') }
  description { Faker::Lorem.sentence(3) }
end
