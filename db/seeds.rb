# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(email: 'lukas@example.com', password: 'password', full_name: 'Lukas Nimmo')

Category.create(name: 'Drama')
Category.create(name: 'Comedy')
Category.create(name: 'Sleuthing')


Video.create(title: "Family Guy", description: "A dad, a talking dog, and a talking baby.", small_cover_url: "/tmp/family_guy.jpg", large_cover_url: "/tmp/family_guy.jpg", category_id: 1)
Video.create(title: "Family Guy", description: "A dad, a talking dog, and a talking baby.", small_cover_url: "/tmp/family_guy.jpg", large_cover_url: "/tmp/family_guy.jpg", category_id: 1)
Video.create(title: "Monk", description: "A clean detective", small_cover_url: "/tmp/monk.jpg", large_cover_url: "/tmp/monk_large.jpg", category_id: 1)
Video.create(title: "South Park", description: "Young kids with crazy adventures.", small_cover_url: "/tmp/south_park.jpg", large_cover_url: "/tmp/south_park.jpg", category_id: 1)
Video.create(title: "Family Guy", description: "A dad, a talking dog, and a talking baby.", small_cover_url: "/tmp/family_guy.jpg", large_cover_url: "/tmp/family_guy.jpg", category_id: 1)
Video.create(title: "Monk", description: "A clean detective", small_cover_url: "/tmp/monk.jpg", large_cover_url: "/tmp/monk_large.jpg", category_id: 1)
Video.create(title: "South Park", description: "Young kids with crazy adventures.", small_cover_url: "/tmp/south_park.jpg", large_cover_url: "/tmp/south_park.jpg", category_id: 1)


Video.create(title: "Monk", description: "A clean detective", small_cover_url: "/tmp/monk.jpg", large_cover_url: "/tmp/monk_large.jpg", category_id: 2)

south_park = Video.create(title: "South Park", description: "Young kids with crazy adventures.", small_cover_url: "/tmp/south_park.jpg", large_cover_url: "/tmp/south_park.jpg", category_id: 3)

Review.create(content: 'Great movie!', rating: 5, video: south_park)
Review.create(content: 'Sucked bad!', rating: 1, video: south_park)
