Fabricator(:user) do
  full_name { Faker::Name.name }
  password 'password'
  email { Faker::Internet.email }
end
